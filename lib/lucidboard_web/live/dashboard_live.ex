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
      |> redirect(to: Routes.user_path(Endpoint, :signin_page))

    {:stop, socket}
  end

  def mount(%{user_id: _user_id}, socket) do
    # user = user_id && Account.get_user(user_id)
    Lucidboard.subscribe("short_boards")

    short_boards = Enum.map(Twiddler.boards(), &ShortBoard.from_board/1)

    socket =
      socket
      |> assign(:short_boards, short_boards)

    {:ok, socket}
  end

  def handle_info({:new, short_board}, socket) do
    short_boards = List.insert_at(socket.assigns.short_boards, 0, short_board)
    {:noreply, assign(socket, :short_boards, short_boards)}
  end
end
