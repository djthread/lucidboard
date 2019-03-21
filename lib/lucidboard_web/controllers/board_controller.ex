defmodule LucidboardWeb.BoardController do
  use LucidboardWeb, :controller
  alias Lucidboard.{Board, Column, Twiddler}
  alias LucidboardWeb.BoardLive
  alias LucidboardWeb.Router.Helpers, as: Routes

  @templates Application.get_env(:lucidboard, :templates)

  def index(conn, %{"id" => board_id}) do
    case Twiddler.by_id(board_id) do
      nil -> {:error, :not_found}
      board -> render(conn, "index.html", board: board)
    end
  end

  def create_form(conn, _params) do
    template_options =
      for {name, %{columns: columns}} <- @templates do
        {"#{name} (#{Enum.join(columns, ", ")})", name}
      end

    render(conn, "create.html",
      template_options: template_options,
      token: get_csrf_token()
    )
  end

  def create(conn, %{"title" => title, "template" => template}) do
    columns =
      Enum.map(Enum.with_index(@templates[template].columns), fn {c, idx} ->
        Column.new(title: c, pos: idx)
      end)

    board = Board.new(title: title, columns: columns, user: conn.assigns[:user])

    with {:ok, %Board{id: id}} <- Twiddler.insert(board) do
      {:see_other, Routes.live_path(conn, BoardLive, id)}
    end
  end
end
