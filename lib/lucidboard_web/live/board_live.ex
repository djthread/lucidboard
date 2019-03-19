defmodule LucidboardWeb.BoardLive do
  @moduledoc "The LiveView for a Lucidboard"
  use Phoenix.LiveView
  alias Ecto.Changeset
  alias Lucidboard.{Card, LiveBoard, Presence, Seeds, Twiddler}
  alias Lucidboard.Twiddler.Op
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

        {:ok, socket}
    end
  end

  def terminate(_reason, socket) do
    board_id = socket.assigns.board.id

    if 1 == socket |> topic() |> Presence.list() |> Map.keys() |> length() do
      LiveBoard.stop(board_id)
    end
  end

  def handle_event("add_card", col_id, socket) do
    action = {:add_and_lock_card, col_id: col_id, user_id: @user_id}
    board_id = socket.assigns.board.id

    socket =
      case LiveBoard.call(board_id, {:action, action}) do
        {:ok, %{card: new_card}} ->
          presence_lock_card(socket, new_card)

        {:error, message} ->
          put_flash(socket, :error, message)
      end

    {:noreply, socket}
  end

  def handle_event("inline_edit", card_id, socket) do
    {:ok, card} = Op.card_by_id(socket.assigns.board, card_id)
    {:noreply, presence_lock_card(socket, card)}
  end

  def handle_event("card_save", form_data, socket) do
    socket =
      case Card.changeset(socket.assigns.card, form_data["card"]) do
        %{valid?: true} = changeset ->
          card = Changeset.apply_changes(changeset)
          action = {:update_card, %{id: card.id, body: card.body}}
          {:ok, _} = LiveBoard.call(socket.assigns.board.id, {:action, action})
          finish_card_edit(socket)

        invalid_changeset ->
          assign(socket, card_changeset: invalid_changeset)
      end

    {:noreply, socket}
  end

  def handle_event("card_cancel", _, socket) do
    {:noreply, finish_card_edit(socket)}
  end

  def handle_info({:board, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    id = socket.assigns.board.id
    {:noreply, assign(socket, :online_users, Presence.list("board:#{id}"))}
  end

  defp finish_card_edit(socket) do
    assigns = Map.drop(socket.assigns, [:card, :card_changeset])

    Presence.update(
      self(),
      topic(socket),
      @user_id,
      &Map.drop(&1, [:locked_card_id])
    )

    Map.put(socket, :assigns, assigns)
  end

  defp presence_lock_card(socket, card) do
    Presence.update(
      self(),
      topic(socket),
      @user_id,
      &Map.put(&1, :locked_card_id, card.id)
    )

    socket
    |> assign(:card, card)
    |> assign(:card_changeset, Card.changeset(card))
  end

  def topic(%Socket{} = socket), do: "board:#{socket.assigns.board.id}"
  def topic(board_id), do: "board:#{board_id}"
end
