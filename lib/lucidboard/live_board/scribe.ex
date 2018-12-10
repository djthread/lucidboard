defmodule Lucidboard.LiveBoard.Scribe do
  @moduledoc """
  LiveBoard-specific process, responsible for committing data to the database.

  The idea here is to have a separate process for these Repo calls so the
  user is not blocked by the operation.
  """
  use GenServer
  alias Ecto.{Changeset, Multi}
  alias Lucidboard.Repo
  require Logger

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl true
  def init(nil), do: {:ok, nil}

  @impl true
  def handle_cast(%Changeset{} = cs, state) do
    case Repo.update(cs) do
      {:ok, _struct} ->
        nil

      bad ->
        Logger.error("""
        Repo.update on changeset failed: #{inspect(cs)}: #{inspect(bad)}\
        """)
    end

    {:noreply, state}
  end

  def handle_cast(%Multi{} = multi, state) do
    case Repo.transaction(multi) do
      {:ok, _res} -> nil
      bad -> Logger.error("Bad transaction: #{inspect(bad)}")
    end

    {:noreply, state}
  end

  def handle_cast(fun, state) when is_function(fun) do
    case Repo.transaction(fun) do
      {:ok, _res} -> nil
      bad -> Logger.error("Bad transaction: #{inspect(bad)}")
    end

    {:noreply, state}
  end

  def handle_cast(%{} = struct, _from, state) do
    case Repo.insert(struct) do
      {:ok, _struct} ->
        nil

      bad ->
        Logger.error("""
        Repo.insert failed on #{inspect(struct)}: #{inspect(bad)}\
        """)
    end

    {:noreply, state}
  end
end
