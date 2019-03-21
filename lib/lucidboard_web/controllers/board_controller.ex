defmodule LucidboardWeb.BoardController do
  use LucidboardWeb, :controller
  alias Lucidboard.{Board, Column, Twiddler}
  alias LucidboardWeb.BoardLive
  alias LucidboardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.Controller, as: LiveViewController

  @templates Application.get_env(:lucidboard, :templates)

  def index(conn, %{"id" => board_id}) do
    LiveViewController.live_render(conn, BoardLive,
      session: %{
        id: board_id,
        user_id: get_session(conn, :user_id)
      }
    )
  end

  def create_form(%{assigns: %{user: nil}} = conn, _) do
    {:see_other, Routes.user_path(conn, :signin_page)}
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
      {:see_other, Routes.board_path(conn, :index, id)}
    end
  end
end
