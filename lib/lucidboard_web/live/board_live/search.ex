defmodule LucidboardWeb.BoardLive.Search do
  @moduledoc "The on-board search results"
  alias Lucidboard.Board
  alias Lucidboard.Twiddler.{Op, Glass}

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
      with {:ok, card_path} <- Glass.card_path_by_id(board, card.id),
           {:ok, new_board, _card, _tx_fn} <- Op.cut_card(board, card_path) do
        new_board
      else
        bad -> raise "Unexpected return!: #{inspect(bad)}"
      end
    end
  end
end
