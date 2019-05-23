defmodule LucidboardWeb.DashboardLive do
  @moduledoc "The LiveView for the dashboard page"
  use Phoenix.LiveView
  # alias Ecto.Changeset
  # alias Lucidboard.{Account, Card, Column, LiveBoard, Presence, Twiddler}
  alias Lucidboard.Twiddler
  alias LucidboardWeb.DashboardView
  # alias LucidboardWeb.Router.Helpers, as: Routes
  alias LucidboardWeb.Router.Helpers, as: Routes
  # alias Phoenix.LiveView.Socket
  # alias Phoenix.Socket.Broadcast

  def render(assigns) do
    DashboardView.render("index.html", assigns)
  end

  def mount(%{user_id: nil}, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be signed in")
      |> redirect(to: Routes.user_path(Endpoint, :signin_page))

    {:stop, socket}
  end

  def mount(%{user_id: _user_id}, socket) do
    # user = user_id && Account.get_user(user_id)

    socket =
      socket
      |> assign(:boards, Twiddler.boards())

    {:ok, socket}
  end
end
