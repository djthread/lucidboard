defmodule LucidboardWeb.UserController do
  use LucidboardWeb, :controller
  alias Ecto.Changeset
  alias Lucidboard.{Repo, User}
  alias LucidboardWeb.Router.Helpers, as: Routes

  @themes Application.get_env(:lucidboard, :themes)

  def signin(conn, _params) do
    if signed_in?(conn) do
      conn
      |> put_status(:see_other)
      |> redirect(to: Routes.dashboard_path(conn, :index))
    else
      render(conn, "signin.html")
    end
  end

  def settings(conn, _params) do
    render(conn, "settings.html", user: conn.assigns[:user], themes: @themes)
  end

  def update_settings(conn, params) do
    with %{valid?: true} = u_cs <-
           conn.assigns.user
           |> User.changeset(%{"settings" => params})
           |> Changeset.cast_embed(:settings),
         {:ok, new_user} <- Repo.update(u_cs) do
      conn
      |> assign(:user, new_user)
      |> put_flash(:info, "Your settings have been saved.")
      |> put_status(:see_other)
      |> redirect(to: Routes.user_path(conn, :settings))
    end
  end
end
