defmodule LucidboardWeb.CreateBoardLive do
  @moduledoc "The LiveView for the create board screen"
  use Phoenix.LiveView
  alias Ecto.Changeset
  alias Lucidboard.{Account, Board, Column, BoardSettings, ShortBoard}
  alias LucidboardWeb.{BoardView, Endpoint}

  # alias Lucidboard.Twiddler.Op
  # alias LucidboardWeb.{BoardView, Endpoint}
  alias LucidboardWeb.Router.Helpers, as: Routes
  # alias Phoenix.LiveView.Socket
  # alias Phoenix.Socket.Broadcast

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
    # IO.inspect(params, label: "params")
    # IO.inspect(Routes.board_path(Endpoint, :index, 1))

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

    case Board.changeset(Board.new(), %{
           title: params["title"],
           columns: columns,
           settings: settings,
           user: socket.assigns.user
         }) do
      %{valid?: false} = cs ->
        {:noreply, assign(socket, :board_changeset, cs)}

      cs ->
        # with {:ok, %Board{id: id} = board} <- Twiddler.insert(board) do
        Lucidboard.broadcast(
          "short_boards",
          {:new, cs |> Changeset.apply_changes() |> ShortBoard.from_board()}
        )

        # create the board
        # {:see_other, Routes.board_path(conn, :index, id)}
        nil
    end
  end
end
