defmodule Lb2.LiveBoard do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lb2.Twiddler
  alias Lb2.Board.{Board, Event}
  require Logger

  @registry Lb2.BoardRegistry

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
    case invoke_carefully({Twiddler, :act, [state.board, action]}) do
      {:ok, new_board, change, event} ->
        scribe(change, new_board.id)
        new_state = %{state | board: new_board, events: [event | state.events]}
        {:reply, new_board, new_state}

      {:error, bad} ->
        {:reply, bad, state}

      {:caught, type, error, stacktrace} ->
        Logger.error("""
        Error executing action #{inspect(action)}: \
        #{Exception.format(type, error, stacktrace)}\
        """)

        {:reply, :error, state}
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

  defp invoke_carefully({mod, fun, args}) do
    apply(mod, fun, args)
  catch
    type, error -> {:caught, type, error, __STACKTRACE__}
  end

  # def create_card(column_id, content) do
  #   with %Column{} = col <- column_by_id(column_id),
  #        {:ok, card} <- do_create_card(content) do
  #     append_card_to_column(col, card)
  #   else
  #     nil -> {:error, "Column not found"}
  #   end
  # end

  # def append_card_to_column(%Column{} = col, %Card{} = card) do
  #   cards = col.cards ++ [card.id]

  #   with %{valid?: true} = changeset <- Column.changeset(col, %{cards: cards}) do
  #     Repo.update(changeset)
  #   end
  # end

  # defp column_by_id(column_id) do
  #   Repo.one(from(c in Column, where: c.id == ^column_id, select: c))
  # end

  # defp do_create_card(content) do
  #   %Card{}
  #   |> Card.changeset(%{content: content})
  #   |> Repo.insert()
  # end

  # defp create_board(column_names) do
  #   column_ids = Enum.map(column_names, &create_column/1)

  #   data = %{name: "Test board", columns: column_ids}

  #   changeset = Board.changeset(%Board{}, data)

  #   Repo.insert(changeset)
  # end

  # defp create_column(name) do
  #   {:ok, column} =
  #     %Column{}
  #     |> Column.changeset(%{name: name})
  #     |> Repo.insert()

  #   column.id
  # end
end
