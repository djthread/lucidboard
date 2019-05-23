defmodule Lucidboard.LiveBoard.Scribe do
  @moduledoc """
  LiveBoard-specific process, responsible for committing data to the database.

  The idea here is to have a separate process for these Repo calls so the
  user is not blocked by the operation.
  """
  use GenServer
  alias Lucidboard.{LiveBoard, Repo}
  require Logger

  @type tx_fn :: fun | [fun]

  @doc "Cast a write operation to the scribe process"
  @spec write(integer, tx_fn) :: :ok
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
  def handle_cast(tx_fn, state) do
    case execute_tx_fn(tx_fn) do
      {:ok, _struct} -> nil
      nil -> nil
      bad -> Logger.error("Repo.update on changeset failed: #{inspect(bad)}")
    end

    {:noreply, state}
  end

  def execute_tx_fn(functions, tx \\ true)

  def execute_tx_fn(functions, tx) when is_list(functions) do
    go = fn ->
      Enum.each(functions, fn fun -> execute_tx_fn(fun, false) end)
    end

    if tx, do: Repo.transaction(go), else: go.()
  end

  def execute_tx_fn(nil, _), do: nil

  def execute_tx_fn(fun, tx) do
    if tx, do: Repo.transaction(fun), else: fun.()
  end
end
