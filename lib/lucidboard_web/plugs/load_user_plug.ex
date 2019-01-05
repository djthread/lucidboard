defmodule LucidboardWeb.LoadUserPlug do
  @moduledoc "Load the User struct (or `nil`) into conn.assigns."
  import Plug.Conn
  import Ecto.Query
  alias Lucidboard.{Repo, User}

  @default_theme Application.get_env(:lucidboard, :default_theme)

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Repo.one(from(User, limit: 1))
    IO.puts "Loaded user with theme #{user.settings.theme}"

    theme_css =
      with t when t in ["default", nil] <- user.settings.theme do
        @default_theme
      end

    conn
    |> assign(:user, user)
    |> assign(:theme_css, theme_css <> ".css")
  end
end
