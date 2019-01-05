defmodule LucidboardWeb.FallbackController do
  use Phoenix.Controller
  alias LucidboardWeb.ErrorView
  require Logger

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(ErrorView)
    |> render(:"403")
  end

  def call(conn, {redirect_type, location})
      when redirect_type in [:see_other, :moved_permanently] do
    conn
    |> put_status(redirect_type)
    |> redirect(to: location)
  end

  def call(conn, {:error, message}) do
    Logger.error("Error on #{conn.request_path}: #{message}")

    conn
    |> put_status(500)
  end
end
