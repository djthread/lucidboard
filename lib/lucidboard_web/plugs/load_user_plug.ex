defmodule LucidboardWeb.LoadUserPlug do
  @moduledoc "Load the User struct (or `nil`) into conn.assigns."
  import Ecto.Query
  import Plug.Conn
  alias Lucidboard.{Repo, User}

  @default_theme Application.get_env(:lucidboard, :default_theme)

  def init(opts), do: opts

  def call(conn, _opts) do
    {conn, user} =
      case get_session(conn, :user_id) do
        nil ->
          {assign_theme(conn), nil}

        user_id ->
          user = Repo.one(from(u in User, where: u.id == ^user_id))
          {assign_theme(conn), user}
      end

    assign(conn, :user, user)
  end

  defp assign_theme(conn) do
    user = conn.assigns[:user]

    theme_css =
      if is_nil(user) or user.settings.theme in ["default", nil] do
        @default_theme
      else
        user.settings.theme
      end

    assign(conn, :theme_css, theme_css <> ".css")
  end
end
