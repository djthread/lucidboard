defmodule LucidboardWeb.DashboardController do
  use LucidboardWeb, :controller
  alias LucidboardWeb.DashboardLive
  alias LucidboardWeb.Router.Helpers, as: Routes
  alias Phoenix.LiveView.Controller, as: LiveViewController

  def index(%{assigns: %{user: nil}} = conn, _) do
    {:see_other, Routes.user_path(conn, :signin_page)}
  end

  def index(conn, _params) do
    LiveViewController.live_render(conn, DashboardLive,
      session: %{
        user_id: get_session(conn, :user_id)
      }
    )
  end
end
