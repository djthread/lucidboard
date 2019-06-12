defmodule LucidboardWeb.BoardLive.Search do
  @moduledoc "The on-board search results"
  alias Lucidboard.Board
  alias Lucidboard.Twiddler.Actions

  @type t :: %__MODULE__{
          q: String.t(),
          board: Board.t()
        }

  defstruct [:q, :board]

  # credo:disable-for-lines:10 Credo.Check.Refactor.Nesting
  @spec query(String.t() | t, Board.t()) :: Board.t()
  def query(%__MODULE__{q: q}, board) do
    query(q, board)
  end

  def query(q, board) do
    Enum.reduce(board.columns, board, fn col, acc_board ->
      Enum.reduce(col.piles, acc_board, fn pile, acc_board2 ->
        Enum.reduce(pile.cards, acc_board2, fn card, acc_board3 ->
          do_reduce_by_query(acc_board3, card, q)
        end)
      end)
    end)
  end

  defp do_reduce_by_query(board, card, q) do
    match =
      if Regex.match?(~r/[A-Z]/, q) do
        String.contains?(card.body, q)
      else
        String.contains?(String.downcase(card.body), String.downcase(q))
      end

    if match do
      board
    else
      {:ok, new_board, _tx_fn, _, _event} =
        Actions.delete_card(board, %{id: card.id})

      new_board
    end
  end
end
