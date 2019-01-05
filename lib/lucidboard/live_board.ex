defmodule Lucidboard.LiveBoard do
  @moduledoc """
  Facade functions for a system that manages Lucidboard states.

  To use, install the child specs returned from `&registry_child_spec/0` and
  `&dynamic_supervisor_child_spec/0` into your supervision tree. Then, use
  the start and stop functions to manage LiveBoard processes and the call
  function to interact with a running one.
  """
  alias Lucidboard.LiveBoard.{Agent, Scribe}

  @registry Lucidboard.BoardRegistry
  @supervisor Lucidboard.BoardSupervisor

  @spec registry_child_spec :: Supervisor.child_spec()
  def registry_child_spec do
    {Registry, keys: :unique, name: @registry}
  end

  @spec dynamic_supervisor_child_spec :: Supervisor.child_spec()
  def dynamic_supervisor_child_spec do
    {DynamicSupervisor, name: @supervisor, strategy: :one_for_one}
  end

  @doc """
  Starts a LiveBoard

  * Pass a board id to load from the db
  * Pass a `%Board{}` either
    * With an `:id`
    * Without an `:id` - board will be inserted first.
  """
  @spec start(integer, keyword) ::
          DynamicSupervisor.on_start_child()
          | {:error, :no_board}
          | {:error, Ecto.Changeset.t()}
  def start(id, opts \\ []) when is_integer(id) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)

    scribe_name = {:via, Registry, {registry, {:scribe, id}}}
    scribe_child_spec = {Scribe, scribe_name}
    DynamicSupervisor.start_child(supervisor, scribe_child_spec)

    name = {:via, Registry, {registry, {:agent, id}}}
    child_spec = {Agent, {id, name}}
    DynamicSupervisor.start_child(supervisor, child_spec)
  end

  @doc "Stops a LiveBoard process by its board id"
  @spec stop(integer) :: :ok | {:error, :not_found}
  def stop(id, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    registry = Keyword.get(opts, :registry, @registry)

    [{agent_pid, nil}] = Registry.lookup(registry, {:agent, id})
    DynamicSupervisor.terminate_child(supervisor, agent_pid)

    [{scribe_pid, nil}] = Registry.lookup(registry, {:scribe, id})
    DynamicSupervisor.terminate_child(supervisor, scribe_pid)
  end

  @doc "Uses GenServer.call to act upon a LiveBoard"
  def call(board_id, msg, opts \\ []) do
    registry = Keyword.get(opts, :registry, @registry)
    name = {:via, Registry, {registry, {:agent, board_id}}}

    GenServer.call(name, msg)
  end
end
