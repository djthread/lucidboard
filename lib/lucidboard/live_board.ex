defmodule Lucidboard.LiveBoard do
  @moduledoc """
  Facade functions for a system that manages Lucidboard states.

  To use, install the child specs returned from `&registry_child_spec/0` and
  `&dynamic_supervisor_child_spec/0` into your supervision tree. Then, use
  the start and stop functions to manage LiveBoard processes and the call
  function to interact with a running one.
  """
  alias Lucidboard.LiveBoard.{Agent, BoardRegistry, BoardSupervisor, Scribe}

  @spec registry_child_spec :: Supervisor.child_spec()
  def registry_child_spec do
    {Registry, keys: :unique, name: BoardRegistry}
  end

  @spec dynamic_supervisor_child_spec :: Supervisor.child_spec()
  def dynamic_supervisor_child_spec do
    {DynamicSupervisor, name: BoardSupervisor, strategy: :one_for_one}
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
    supervisor = Keyword.get(opts, :supervisor, BoardSupervisor)
    registry = Keyword.get(opts, :registry, BoardRegistry)

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
    supervisor = Keyword.get(opts, :supervisor, BoardSupervisor)
    registry = Keyword.get(opts, :registry, BoardRegistry)

    case Registry.lookup(registry, {:agent, id}) do
      [{agent_pid, nil}] ->
        DynamicSupervisor.terminate_child(supervisor, agent_pid)

      _ ->
        nil
    end

    case Registry.lookup(registry, {:scribe, id}) do
      [{scribe_pid, nil}] ->
        DynamicSupervisor.terminate_child(supervisor, scribe_pid)

      _ ->
        nil
    end
  end

  @doc "Uses GenServer.call to act upon a LiveBoard Agent"
  def call(board_id, msg, opts \\ []) do
    board_id
    |> via_agent(Keyword.get(opts, :registry, BoardRegistry))
    |> GenServer.call(msg)
  end

  @doc "Returns the via tuple for accessing the Agent process."
  def via_agent(board_id, registry \\ BoardRegistry),
    do: {:via, Registry, {registry, {:agent, board_id}}}

  @doc "Returns the via tuple for accessing the Scribe process."
  def via_scribe(board_id, registry \\ BoardRegistry),
    do: {:via, Registry, {registry, {:scribe, board_id}}}
end
