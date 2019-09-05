defmodule LucidboardWeb.DashboardLive do
  @moduledoc "The LiveView for the dashboard page"
  use Phoenix.LiveView
  alias Lucidboard.{ShortBoard, Twiddler}
  alias LucidboardWeb.{DashboardView, Endpoint}
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
    Lucidboard.subscribe("dashboards")

    socket =
      socket
      |> assign(
        user_id: user_id,
        subscriptions: MapSet.new()
      )
      |> load_data_and_handle_subscriptions()

    {:ok, socket}
  end

  def handle_info(:full_reload, socket) do
    {:noreply, load_data_and_handle_subscriptions(socket)}
  end

  def handle_info({:short_board, short_board}, socket) do
    short_boards =
      socket.assigns.short_boards
      |> Enum.find_index(fn sb -> sb.id == short_board.id end)
      |> case do
        nil -> socket.assigns.short_boards
        idx -> List.replace_at(socket.assigns.short_boards, idx, short_board)
      end

    {:noreply, assign(socket, :short_boards, short_boards)}
  end

  def handle_event("search", %{"q" => search_key}, socket) do
    {:noreply, load_data_and_handle_subscriptions(socket, 0, search_key)}
  end

  def handle_event("paginate", direction, socket) do
    socket =
      load_data_and_handle_subscriptions(
        socket,
        if(direction == "prev", do: -1, else: 1),
        socket.assigns.search_key
      )

    {:noreply, socket}
  end

  # Loads all dashboard data and updates subscriptions to reflect the visible
  # boards.
  defp load_data_and_handle_subscriptions(socket, page_direction \\ 0, q \\ nil) do
    search_key = q || socket.assigns[:search_key]

    board_pagination =
      Twiddler.boards(
        socket.assigns.user_id,
        (get_page_number(socket) || 1) + page_direction,
        search_key
      )

    short_boards = Enum.map(board_pagination, &ShortBoard.from_board/1)
    new_subscriptions = short_boards |> Enum.map(& &1.id) |> MapSet.new()
    orig_subscriptions = socket.assigns.subscriptions

    Enum.each(MapSet.difference(orig_subscriptions, new_subscriptions), fn id ->
      Lucidboard.unsubscribe("short_board:#{id}")
    end)

    Enum.each(MapSet.difference(new_subscriptions, orig_subscriptions), fn id ->
      Lucidboard.subscribe("short_board:#{id}")
    end)

    assign(socket,
      short_boards: short_boards,
      board_pagination: board_pagination,
      subscriptions: new_subscriptions,
      search_key: search_key
    )
  end

  defp get_page_number(%{assigns: %{board_pagination: %{page_number: num}}}),
    do: num

  defp get_page_number(_), do: nil
end
