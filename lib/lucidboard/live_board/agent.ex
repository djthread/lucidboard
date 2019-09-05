defmodule Lucidboard.LiveBoard.Agent do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lucidboard.{Board, Event, ShortBoard, TimeMachine, Twiddler, User}
  alias Lucidboard.LiveBoard.Scribe
  require Logger

  defmodule State do
    @moduledoc """
    The state of a live board

    * `:board` - The current state as `%Board{}`
    * `:events` - The most recent page of events that have occurred
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
    Logger.info("Initializing board agent (id #{board_id})")

    case {Twiddler.by_id(board_id), TimeMachine.events(board_id)} do
      {%Board{} = board, events} -> {:ok, %State{board: board, events: events}}
      _ -> {:stop, :not_found}
    end
  end

  @impl true
  def handle_call({:action, action}, from, state) do
    handle_call({:action, action, []}, from, state)
  end

  @impl true
  def handle_call({:action, action, opts}, _from, state) when is_list(opts) do
    case Twiddler.act(state.board, action, opts) do
      {:ok, new_board, tx_fn, meta, event} ->
        user = Keyword.get(opts, :user)
        {event, events} = add_event(state.events, event, new_board, user)
        new_state = %{state | board: new_board, events: events}

        if event.desc =~ ~r/board access/ do
          # If the last event changed the board access setting, we'll wait a
          # moment to be sure the Scribe has written to the database, then
          # broadcast to have all Dashboard views do a full refresh.
          Process.send_after(self(), :reload_all_dashboards, 200)
        end

        Lucidboard.broadcast(
          "board:#{new_board.id}",
          {:update, new_board, event}
        )

        Lucidboard.broadcast(
          "short_board:#{new_board.id}",
          {:short_board, ShortBoard.from_board(new_board, events)}
        )

        Scribe.write(new_board.id, [
          tx_fn,
          if(event, do: fn -> TimeMachine.commit(event) end)
        ])

        ret =
          if Keyword.get(opts, :return_board, false),
            do: %{meta | board: new_board},
            else: meta

        {:reply, {:ok, ret}, new_state}

      {:error, message} ->
        {:reply, {:error, message}, state}
    end
  end

  def handle_call(:state, _from, state) do
    ret = %{board: state.board, events: state.events}
    {:reply, ret, state}
  end

  def handle_call({:likes_left_for, %User{id: _user_id}}, _from, state) do
    {:reply, :tbi, state}
  end

  def handle_call(:events, _from, state) do
    {:reply, state.events, state}
  end

  @impl true
  def handle_info(:reload_all_dashboards, state) do
    Lucidboard.broadcast("dashboards", :full_reload)
    {:noreply, state}
  end

  defp add_event(events, nil, _board, _user) do
    {nil, events}
  end

  defp add_event(events, event, board, user) do
    event = %{event | board: board, user: user}
    events = Enum.slice([event | events], 0, TimeMachine.page_size())

    {event, events}
  end
end
