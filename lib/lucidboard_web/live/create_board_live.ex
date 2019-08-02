defmodule LucidboardWeb.CreateBoardLive do
  @moduledoc "The LiveView for the create board screen"
  use Phoenix.LiveView
  alias Ecto.Changeset
  alias Lucidboard.{Account, Board, BoardSettings, Column, Twiddler}
  alias LucidboardWeb.{BoardLive, BoardView, Endpoint}
  alias LucidboardWeb.Router.Helpers, as: Routes

  @templates Application.get_env(:lucidboard, :templates)

  def render(assigns) do
    BoardView.render("create_board.html", assigns)
  end

  def mount(%{user_id: nil}, socket) do
    socket =
      socket
      |> put_flash(:error, "You must be signed in")
      |> redirect(to: Routes.user_path(Endpoint, :signin))

    {:stop, socket}
  end

  def mount(params, socket) do
    template_options =
      for %{name: name, columns: columns} <- @templates do
        {"#{name} (#{Enum.join(columns, ", ")})", name}
      end

    socket =
      socket
      |> assign(:user, params.user_id && Account.get(params.user_id))
      |> assign(:template_options, template_options)
      |> assign(
        :board_changeset,
        Board.changeset(Board.new())
      )

    {:ok, socket}
  end

  def handle_event("create", %{"board" => params}, socket) do
    {columns, settings} =
      case Enum.find(@templates, fn t -> t.name == params["template"] end) do
        nil ->
          {nil, nil}

        tpl ->
          {
            Enum.map(Enum.with_index(tpl.columns), fn {c, idx} ->
              Column.new([title: c, pos: idx], :just_map)
            end),
            BoardSettings.new(tpl.settings, :just_map)
          }
      end

    [
      title: params["title"],
      columns: columns,
      settings: settings,
      user: socket.assigns.user
    ]
    |> Board.new()
    |> Twiddler.insert()
    |> case do
      {:error, %Changeset{} = cs} ->
        {:noreply, assign(socket, :board_changeset, cs)}

      {:ok, %Board{id: id}} ->
        {:stop, redirect(socket, to: Routes.live_path(socket, BoardLive, id))}
    end
  end
end
