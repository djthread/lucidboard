defmodule Lucidboard.LiveBoard do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lucidboard.Twiddler
  alias Lucidboard.Board.{Board, Event}
  require Logger

  @registry Lucidboard.BoardRegistry

  defmodule State do
    @moduledoc """
    The state of a live board

    * `:board` - The current state as `%Board{}`
    * `:events` - List of events that have occurred
    """
    defstruct board: nil, changeset: nil, events: []

    @type t :: %__MODULE__{
            board: Board.t(),
            events: [Event.t()]
          }
  end

  def start_link({board_id, name}) do
    GenServer.start_link(__MODULE__, board_id, name: name)
  end

  @impl true
  def init(board_id) do
    case Twiddler.by_id(board_id) do
      %Board{} = board -> {:ok, %State{board: board}}
      nil -> {:stop, "Board id #{board_id} not found!"}
    end
  end

  @impl true
  def handle_call({:action, action}, _from, state) do
    # case invoke_carefully({Twiddler, :act, [state.board, action]}) do
    case Twiddler.act(state.board, action) do
      {:ok, new_board, tx_fn, event} ->
        scribe(tx_fn, new_board.id)
        new_state = %{state | board: new_board, events: [event | state.events]}
        {:reply, new_board, new_state}

      {:error, bad} ->
        {:reply, bad, state}

      # {:caught, type, error, stacktrace} ->
      #   Logger.error("""
      #   Error executing action #{inspect(action)}: \
      #   #{Exception.format(type, error, stacktrace)}\
      #   """)

      #   {:reply, :error, state}
    end
  end

  def handle_call(:board, _from, state) do
    {:reply, state.board, state}
  end

  def handle_call(:events, _from, state) do
    {:reply, state.events, state}
  end

  defp scribe(change, board_id) do
    name = {:via, Registry, {@registry, {:scribe, board_id}}}
    GenServer.cast(name, change)
  end

  # TODO - we should probably delete this. unnecessary/antipattern.
  # defp invoke_carefully({mod, fun, args}) do
  #   apply(mod, fun, args)
  # catch
  #   type, error -> {:caught, type, error, __STACKTRACE__}
  # end
end
