defmodule Lb2.Twiddler.Glass do
  @moduledoc "Provides lens-building functionality"
  import Focus
  alias Lb2.Board.Board

  @type lens_or_error :: Lens.t() | :error

  @doc "Get a lens for a column by its id"
  @spec column_by_id(Board.t(), integer) :: lens_or_error
  def column_by_id(%Board{columns: columns}, id) do
    case Enum.find_index(columns, fn %{id: i} -> i == id end) do
      nil -> :error
      idx -> {:ok, Lens.make_lens(:columns) ~> Lens.idx(idx)}
    end
  end

  def pile_by_id(%Board{columns: columns}, id) do
    Enum.each(Enum.with_index(columns), fn {col, col_idx} ->
      Enum.each(Enum.with_index(col.piles), fn
        {%{id: ^id}, pile_idx} ->
          throw(
            Lens.make_lens(:columns)
            ~> Lens.idx(col_idx)
            ~> Lens.make_lens(:piles)
            ~> Lens.idx(pile_idx)
          )

        _ ->
          nil
      end)
    end)

    :error
  catch
    lens -> {:ok, lens}
  end

  @spec card_by_id(Board.t(), integer) :: lens_or_error
  def card_by_id(%Board{columns: columns}, id) do
    Enum.each(Enum.with_index(columns), fn {col, col_idx} ->
      Enum.each(Enum.with_index(col.piles), fn {pile, pile_idx} ->
        Enum.each(Enum.with_index(pile.cards), fn
          {%{id: ^id}, card_idx} ->
            throw(
              Lens.make_lens(:columns)
              ~> Lens.idx(col_idx)
              ~> Lens.make_lens(:piles)
              ~> Lens.idx(pile_idx)
              ~> Lens.make_lens(:cards)
              ~> Lens.idx(card_idx)
            )

          _ ->
            nil
        end)
      end)
    end)

    :error
  catch
    lens -> {:ok, lens}
  end
end
