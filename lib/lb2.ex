defmodule Lb2 do
  @moduledoc """
  Exposes high-level Lb2 functionality
  """
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
  def start_live_board(id, opts \\ []) when is_integer(id) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)
    name = {:via, Registry, {registry, id}}
    child_spec = {LiveBoard, {id, name}}

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
