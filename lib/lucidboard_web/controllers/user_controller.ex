defmodule LucidboardWeb.UserController do
  use LucidboardWeb, :controller
  import Ecto.Query
  alias Ecto.Changeset
  alias Lucidboard.{Repo, User}
  alias LucidboardWeb.Router.Helpers, as: Routes

  @themes Application.get_env(:lucidboard, :themes)

  def signin_page(conn, _params) do
    render(conn, "signin.html")
  end

  def signin(conn, %{"signin" => %{"username" => username}}) do
    case Repo.one(from(u in User, where: u.name == ^username)) do
      nil ->
        {:ok, user} = Repo.insert(User.new(name: username))

        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, """
        We've created your account and you're now signed in!
        """)
        |> redirect(to: Routes.dashboard_path(conn, :index))

      # |> put_flash(:error, "Invalid Email or Password")
      # |> render("signin.html")

      user ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "You have successfully signed in!")
        |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end

  def signout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "You have been signout out.")
    |> put_status(:see_other)
    |> redirect(to: Routes.page_path(conn, :index))
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
