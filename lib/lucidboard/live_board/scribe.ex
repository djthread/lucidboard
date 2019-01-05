defmodule Lucidboard.LiveBoard.Scribe do
  @moduledoc """
  LiveBoard-specific process, responsible for committing data to the database.

  The idea here is to have a separate process for these Repo calls so the
  user is not blocked by the operation.
  """
  use GenServer
  alias Lucidboard.{LiveBoard, Repo}
  require Logger

  @doc "Cast a write operation to the scribe process"
  @spec write(integer, function) :: :ok
  def write(board_id, tx_fn) do
    board_id
    |> LiveBoard.via_scribe()
    |> GenServer.cast(tx_fn)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl true
  def init(nil), do: {:ok, nil}

  @impl true
  def handle_cast(tx_fn, state) when is_function(tx_fn) do
    case Repo.transaction(tx_fn) do
      {:ok, _struct} -> nil
      bad -> Logger.error("Repo.update on changeset failed: #{inspect(bad)}")
    end

    {:noreply, state}
  end
end
