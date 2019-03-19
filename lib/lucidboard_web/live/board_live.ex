defmodule LucidboardWeb.BoardLive do
  @moduledoc "The LiveView for a Lucidboard"
  use Phoenix.LiveView
  alias Lucidboard.{LiveBoard, Twiddler}
  alias LucidboardWeb.BoardView

  def render(assigns) do
    BoardView.render("index.html", assigns)
  end

  def mount(%{path_params: %{"id" => board_id}}, socket) do
    case Twiddler.by_id(board_id) do
      nil ->
        {:stop, put_flash(socket, :error, "Board not found")}

      board ->
        Lucidboard.subscribe("board:#{board_id}")
        {:ok, assign(socket, :board, board)}
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
end
