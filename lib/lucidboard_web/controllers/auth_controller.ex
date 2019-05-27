defmodule LucidboardWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use LucidboardWeb, :controller
  plug(Ueberauth)

  alias Ueberauth.Strategy.Helpers
  import Ecto.Query
  alias Ecto.Changeset
  alias Lucidboard.{Repo, User}
  alias LucidboardWeb.Router.Helpers, as: Routes

  require Logger

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # %{avatar: "https://avatars2.githubusercontent.com/u/7450573?v=4", id: 7450573, name: "Igor O'sten", nickname: "borodark"}

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        %{id: id, name: username, nickname: nickname }  = user
        case Repo.one(from(u in User, where: u.name == ^username)) do
          nil ->
            {:ok, user} = Repo.insert(User.new(name: username))
            conn
            |> put_flash(:info, "Successfully authenticated.")
            |> put_session(:user_id, user.id)
            |> put_flash(:info, """
            We've created your account and you're now signed in!
            """)
            |> redirect(to: Routes.dashboard_path(conn, :index))
          user ->
            conn
            |> put_flash(:info, "Successfully authenticated.")
            |> configure_session(renew: true)
            |> put_session(:user_id, user.id)
            |> put_flash(:info, "You have successfully signed in!")
            |> redirect(to: Routes.dashboard_path(conn, :index))
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
