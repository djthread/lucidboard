defmodule Lucidboard do
  @moduledoc """
  Exposes high-level Lucidboard functionality
  """
  alias Lucidboard.Board.Board
  alias Lucidboard.LiveBoard
  alias Lucidboard.LiveBoard.Scribe

  @registry Lucidboard.BoardRegistry
  @supervisor Lucidboard.BoardSupervisor

  @doc """
  Starts a LiveBoard

  * Pass a board id to load from the db
  * Pass a `%Board{}` either
    * With an `:id`
    * Without an `:id` - board will be inserted first.
  """
  @spec start_live_board(integer, keyword) ::
          DynamicSupervisor.on_start_child()
          | {:error, :no_board}
          | {:error, Ecto.Changeset.t()}
  def start_live_board(id, opts \\ []) when is_integer(id) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)

    scribe_name = {:via, Registry, {registry, {:scribe, id}}}
    scribe_child_spec = {Scribe, scribe_name}
    DynamicSupervisor.start_child(supervisor, scribe_child_spec)

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

    [{scribe_pid, nil}] = Registry.lookup(registry, {:scribe, id})
    DynamicSupervisor.terminate_child(supervisor, scribe_pid)
  end

  @doc "Uses GenServer.call to act upon a LiveBoard"
  def call(board_id, msg, opts \\ []) do
    registry = Keyword.get(opts, :registry, @registry)
    name = {:via, Registry, {registry, board_id}}

    GenServer.call(name, msg)
  end
end
