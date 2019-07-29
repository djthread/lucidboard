defmodule LucidboardWeb.CreateBoardLive do
  @moduledoc "The LiveView for the create board screen"
  use Phoenix.LiveView
  alias Lucidboard.Board
  alias LucidboardWeb.{BoardView, Endpoint}

  # alias Lucidboard.Twiddler.Op
  # alias LucidboardWeb.{BoardView, Endpoint}
  alias LucidboardWeb.Router.Helpers, as: Routes
  # alias Phoenix.LiveView.Socket
  # alias Phoenix.Socket.Broadcast

  @templates Application.get_env(:lucidboard, :templates)

  def render(assigns) do
    BoardView.render("create_board.html", assigns)
  end

  def mount(%{user_id: nil}, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be signed in")
      |> redirect(to: Routes.user_path(Endpoint, :signin))

    {:stop, socket}
  end

  def mount(_params, socket) do
    template_options =
      for %{name: name, columns: columns} <- @templates do
        {"#{name} (#{Enum.join(columns, ", ")})", name}
      end

    socket =
      socket
      |> assign(:template_options, template_options)
      |> assign(
        :board_changeset,
        Board.changeset(Board.new())
      )

    {:ok, socket}
  end

  def handle_event("create", %{"board" => params}, socket) do
    IO.inspect(params, label: "params")
    IO.inspect(Routes.board_path(Endpoint, :index, 1))

    template = Enum.find(@templates, fn t -> t.name == template end)

    columns =
      Enum.map(Enum.with_index(template.columns), fn {c, idx} ->
        Column.new(title: c, pos: idx)
      end)

    case Board.changeset(Board.new(), %{
        title: title,
        columns: columns,
        user: conn.assigns[:user],
        settings: BoardSettings.new(template.settings)
    }) do
      %{valid?: false}
    end

    with {:ok, %Board{id: id} = board} <- Twiddler.insert(board) do
      Lucidboard.broadcast("short_boards", {:new, ShortBoard.from_board(board)})
      {:see_other, Routes.board_path(conn, :index, id)}
    end
  end
end
