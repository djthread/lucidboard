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
      nil -> {:stop, put_flash(socket, :error, "Board not found")}
      board -> {:ok, assign(socket, :board, board)}
    end
  end

  def handle_event("add_card", col_id, socket) do
    action = {:add_and_lock_card, col_id: col_id, user_id: 1}
    board = LiveBoard.call(socket.assigns.board.id, {:action, action})

    {:noreply, assign(socket, :board, board)}
  end
end