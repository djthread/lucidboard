defmodule LucidboardWeb.BoardLive do
  @moduledoc "The LiveView for a Lucidboard"
  use Phoenix.LiveView
  alias Lucidboard.{LiveBoard, Presence, Twiddler}
  alias LucidboardWeb.BoardView
  alias Phoenix.Socket.Broadcast

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
        Presence.track(self(), identifier, "bob", %{})
        {:ok, assign(socket, :board, board)}
    end
  end

  def terminate(_reason, socket) do
    board_id = socket.assigns.board.id

    if 1 == "board:#{board_id}" |> Presence.list() |> Map.keys() |> length() do
      LiveBoard.stop(board_id)
    end
  end

  def handle_event("add_card", col_id, socket) do
    action = {:add_and_lock_card, col_id: col_id, user_id: 1}
    LiveBoard.call(socket.assigns.board.id, {:action, action})
    {:noreply, socket}
  end

  @doc "Handle message indicating that the board has been updated"
  def handle_info({:board, board}, socket) do
    {:noreply, assign(socket, :board, board)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    id = socket.assigns.board.id
    {:noreply, assign(socket, :online_users, Presence.list("board:#{id}"))}
  end
end
