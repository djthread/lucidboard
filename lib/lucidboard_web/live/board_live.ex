defmodule LucidboardWeb.BoardLive do
  @moduledoc "The LiveView for a Lucidboard"
  use Phoenix.LiveView
  alias Ecto.Changeset
  alias Lucidboard.{Card, Column, LiveBoard, Presence, Seeds, Twiddler, User}
  alias Lucidboard.Twiddler.Glass
  alias LucidboardWeb.BoardView
  # alias Phoenix.Socket
  alias Phoenix.LiveView.Socket
  alias Phoenix.Socket.Broadcast

  @user_id 1

  def render(assigns) do
    BoardView.render("index.html", assigns)
  end

  def mount(%{path_params: %{"id" => board_id}}, socket) do
    case Twiddler.by_id(board_id) do
      nil ->
        {:stop, put_flash(socket, :error, "Board not found")}

      board ->
        identifier = "board:#{board.id}"
        LiveBoard.start(board.id)
        Lucidboard.subscribe(identifier)
        Presence.track(self(), identifier, @user_id, %{lv_ref: socket.id})

        socket =
          socket
          |> assign(:board, board)
          |> assign(:user, Seeds.get_user())
          |> assign(:modal_open?, false)
          |> assign(:tab, :board)
          |> assign(:column_changeset, Column.changeset(%Column{}, %{}))

        {:ok, socket}
    end
  end

  def terminate(_reason, socket) do
    board_id = socket.assigns.board.id

    if 1 == socket |> topic() |> Presence.list() |> Map.keys() |> length() do
      LiveBoard.stop(board_id)
    end
  end

  def handle_event("tab", tab, socket) when tab in ~w(board events options) do
    {:noreply, assign(socket, :tab, String.to_atom(tab))}
  end

  def handle_event("add_card", col_id, socket) do
    action = {:add_and_lock_card, col_id: col_id, user_id: @user_id}
    board_id = socket.assigns.board.id

    {:ok, %{card: new_card}} = LiveBoard.call(board_id, {:action, action})
    socket = presence_lock_card(socket, new_card)

    {:noreply, socket}
  end

  def handle_event("inline_edit", card_id, socket) do
    {:ok, card} = Glass.card_by_id(socket.assigns.board, card_id)
    {:noreply, presence_lock_card(socket, card)}
  end

  def handle_event("card_save", form_data, socket) do
    {_, socket} = save_card(socket, form_data)
    {:noreply, socket}
  end

  def handle_event("modal_card_save", form_data, socket) do
    case save_card(socket, form_data) do
      {:ok, socket} -> {:noreply, assign(socket, :modal_open?, false)}
      {:invalid, socket} -> socket
    end
  end

  def handle_event("modal_card_edit", card_id, socket) do
    {:ok, card} = Glass.card_by_id(socket.assigns.board, card_id)

    socket =
      socket
      |> presence_lock_card(card)
      |> assign(:modal_open?, true)

    {:noreply, socket}
  end

  def handle_event("card_cancel", _, socket) do
    {:noreply, socket |> finish_card_edit() |> assign(:modal_open?, false)}
  end

  def handle_event("like", card_id, socket) do
    board = socket.assigns.board
    action = {:like, id: card_id, user: %User{id: @user_id}}
    {:ok, _} = LiveBoard.call(board.id, {:action, action})
    {:noreply, socket}
  end

  def handle_event("column_add", form_data, socket) do
    column = Changeset.apply_changes(socket.assigns.column_changeset)

    case Column.changeset(column, form_data["column"]) do
      %{valid?: true} = changeset ->
        column = Changeset.apply_changes(changeset)
        action = {:add_column, %{title: column.title}}
        {:ok, _} = LiveBoard.call(socket.assigns.board.id, {:action, action})
        {:noreply, assign(socket, column_changeset: Column.changeset(%Column{}, %{}))}

      invalid_changeset ->
        {:noreply, assign(socket, column_changeset: invalid_changeset)}
    end
  end

  def handle_info({:board, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    id = socket.assigns.board.id
    {:noreply, assign(socket, :online_users, Presence.list("board:#{id}"))}
  end

  defp finish_card_edit(socket) do
    Presence.update(
      self(),
      topic(socket),
      @user_id,
      &Map.drop(&1, [:locked_card_id])
    )

    assigns = Map.drop(socket.assigns, [:card_changeset])
    Map.put(socket, :assigns, assigns)
  end

  defp presence_lock_card(socket, card) do
    Presence.update(
      self(),
      topic(socket),
      @user_id,
      &Map.put(&1, :locked_card_id, card.id)
    )

    assign(socket, :card_changeset, Card.changeset(card))
  end

  @spec save_card(Socket.t(), map) :: {:ok | :invalid, Socket.t()}
  defp save_card(socket, form_data) do
    card = Changeset.apply_changes(socket.assigns.card_changeset)

    case Card.changeset(card, form_data["card"]) do
      %{valid?: true} = changeset ->
        card = Changeset.apply_changes(changeset)
        action = {:update_card, %{id: card.id, body: card.body}}
        {:ok, _} = LiveBoard.call(socket.assigns.board.id, {:action, action})
        {:ok, finish_card_edit(socket)}

      invalid_changeset ->
        {:invalid, assign(socket, card_changeset: invalid_changeset)}
    end
  end

  def topic(%Socket{} = socket), do: "board:#{socket.assigns.board.id}"
  def topic(board_id), do: "board:#{board_id}"
end
