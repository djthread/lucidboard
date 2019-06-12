defmodule LucidboardWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use LucidboardWeb, :controller
  alias Lucidboard.Account
  alias LucidboardWeb.Router.Helpers, as: Routes
  alias Ueberauth.Strategy.Helpers

  plug(Ueberauth)

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def signout(conn, _params) do
    conn
    |> put_flash(:info, "You have been signed out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do

    #require Logger
    #Logger.warn("#{inspect auth}")
    IO.inspect(auth)
    case Account.auth_to_user(auth) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Hello, #{user.name}!")
        # |> configure_session(renew: true)
        |> redirect(to: Routes.dashboard_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
