defmodule LucidboardWeb.DashboardLive do
  @moduledoc "The LiveView for the dashboard page"
  use Phoenix.LiveView
  alias Lucidboard.{ShortBoard, Twiddler}
  alias LucidboardWeb.DashboardView
  alias LucidboardWeb.Router.Helpers, as: Routes

  def render(assigns) do
    DashboardView.render("index.html", assigns)
  end

  def mount(%{user_id: nil}, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be signed in")
      |> redirect(to: Routes.user_path(Endpoint, :signin))

    {:stop, socket}
  end

  def mount(%{user_id: user_id}, socket) do
    Lucidboard.subscribe("short_boards")

    board_pagination = Twiddler.boards(user_id)
    short_boards = Enum.map(board_pagination, &ShortBoard.from_board/1)

    socket =
      assign(socket,
        short_boards: short_boards,
        board_pagination: board_pagination,
        search_key: nil
      )

    {:ok, socket}
  end

  def handle_info({:new, short_board}, socket) do
    short_boards = List.insert_at(socket.assigns.short_boards, 0, short_board)
    {:noreply, assign(socket, :short_boards, short_boards)}
  end

  def handle_event("search", %{"q" => search_key}, socket) do
    board_pagination =
      Twiddler.boards(
        socket.assigns.board_pagination.page_number,
        search_key
      )

    short_boards = Enum.map(board_pagination, &ShortBoard.from_board/1)

    socket =
      socket
      |> assign(:short_boards, short_boards)
      |> assign(:board_pagination, board_pagination)
      |> assign(:search_key, search_key)

    {:noreply, socket}
  end

  def handle_event("paginate", direction, socket) do
    paginate_direction = if direction == "prev", do: -1, else: 1

    board_pagination =
      Twiddler.boards(
        socket.assigns.board_pagination.page_number + paginate_direction,
        socket.assigns.search_key
      )

    short_boards = Enum.map(board_pagination, &ShortBoard.from_board/1)

    socket =
      socket
      |> assign(:short_boards, short_boards)
      |> assign(:board_pagination, board_pagination)

    {:noreply, socket}
  end
end
