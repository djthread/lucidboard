defmodule Lb2 do
  @moduledoc """
  Lb2 keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Lb2.Board, as: B
  alias Lb2.Board.Board
  alias Lb2.LiveBoard

  @registry Lb2.BoardRegistry
  @supervisor Lb2.BoardSupervisor

  @doc """
  Starts a LiveBoard

  * Pass a board id to load from the db
  * Pass a `%Board{}` either
    * With an `:id`
    * Without an `:id` - board will be inserted first.
  """
  @spec start_live_board(integer | Board.t(), keyword) ::
          DynamicSupervisor.on_start_child()
          | {:error, :no_board}
          | {:error, Ecto.Changeset.t()}
  def start_live_board(id_or_board, opts \\ [])

  def start_live_board(id, opts) when is_integer(id) do
    case B.by_id(id) do
      nil -> {:error, :no_board}
      board -> start_live_board(board, opts)
    end
  end

  def start_live_board(%Board{id: nil} = board, opts) do
    with {:ok, new_board} <- B.insert(board) do
      start_live_board(new_board, opts)
    end
  end

  def start_live_board(%Board{} = board, opts) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)
    name = {:via, Registry, {registry, board.id}}
    child_spec = {LiveBoard, {board, name}}

    DynamicSupervisor.start_child(supervisor, child_spec)
  end

  @doc "Stops a LiveBoard process by its board id"
  @spec stop_live_board(integer) :: :ok | {:error, :not_found}
  def stop_live_board(id, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)
    [{pid, nil}] = Registry.lookup(registry, id)

    DynamicSupervisor.terminate_child(supervisor, pid)
  end

  @doc "Uses GenServer.call to act upon a LiveBoard"
  def call(board_id, msg, opts \\ []) do
    registry = Keyword.get(opts, :registry, @registry)
    name = {:via, Registry, {registry, board_id}}

    GenServer.call(name, msg)
  end
end
