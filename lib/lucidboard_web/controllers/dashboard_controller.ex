defmodule LucidboardWeb.DashboardController do
  use LucidboardWeb, :controller
  alias Lucidboard.Twiddler
  alias LucidboardWeb.Router.Helpers, as: Routes

  def index(%{assigns: %{user: nil}} = conn, _) do
    {:see_other, Routes.user_path(conn, :signin_page)}
  end

  def index(conn, _params) do
    render(conn, "index.html", boards: Twiddler.boards())
  end
end
