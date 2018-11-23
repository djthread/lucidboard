defmodule Lb2.LiveBoard do
  @moduledoc """
  GenServer for a live board
  """
  use GenServer
  alias Lb2.Board.Board
  # alias Lb2.Board.{Board, Card, Column}
  alias Lb2.Board, as: B

  def start_link({board, name}) do
    with {:ok, pid} <- GenServer.start_link(__MODULE__, board, name: name) do
      {:ok, pid, board}
    end
  end

  @impl true
  def init(%Board{id: nil}),
    do: {:stop, "Board must exist in the database. (:id was nil.)"}

  def init(%Board{} = board), do: {:ok, board}

  @impl true
  def handle_call(msg, _from, board) do
    case B.act(board, msg) do
      {:ok, new_board} -> {:reply, new_board, new_board}
      {:error, bad} -> {:reply, bad, board}
    end
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
