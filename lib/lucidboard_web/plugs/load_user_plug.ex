defmodule LucidboardWeb.LoadUserPlug do
  @moduledoc "Load the User struct (or `nil`) into conn.assigns."
  import Plug.Conn
  alias Lucidboard.Seeds

  @default_theme Application.get_env(:lucidboard, :default_theme)

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Seeds.get_user()

    theme_css =
      with t when t in ["default", nil] <- user.settings.theme do
        @default_theme
      end

    conn
    |> assign(:user, user)
    |> assign(:theme_css, theme_css <> ".css")
  end
end
