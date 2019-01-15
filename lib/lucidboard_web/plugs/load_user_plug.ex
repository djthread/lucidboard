defmodule LucidboardWeb.LoadUserPlug do
  @moduledoc "Load the User struct (or `nil`) into conn.assigns."
  import Plug.Conn
  import Ecto.Query
  alias Lucidboard.{Repo, User}

  @default_theme Application.get_env(:lucidboard, :default_theme)

  def init(opts), do: opts

  def call(conn, _opts) do
    user = get_a_user_i_dont_care()
    IO.puts "Loaded user with theme #{user.settings.theme}"

    theme_css =
      with t when t in ["default", nil] <- user.settings.theme do
        @default_theme
      end

    conn
    |> assign(:user, user)
    |> assign(:theme_css, theme_css <> ".css")
  end

  defp get_a_user_i_dont_care do
    Repo.one(from(u in User, where: u.name == "bob"))
    || Repo.insert!(User.new(name: "bob"))
  end
end
