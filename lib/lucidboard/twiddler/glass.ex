defmodule Lucidboard.Twiddler.Glass do
  @moduledoc """
  Provides lens-building functionality

  A "lens path" is a list of lenses, always using the board itself as the
  subject. This is useful because a list of lenses to a card can be used to
  compose not just the full lens to the card, but also a lens to its
  enclosing pile.
  """
  import Focus
  alias Lucidboard.Board

  @type path :: [Lens.t()]
  @type lens_or_not_found :: {:ok, Lens.t()} | :not_found
  @type lens_path_or_not_found :: {:ok, [Lens.t()]} | :not_found

  @doc "Get a lens for a column by its id"
  @spec column_by_id(Board.t(), integer) :: lens_or_not_found
  def column_by_id(%Board{columns: columns}, id) do
    case Enum.find_index(columns, fn %{id: i} -> i == id end) do
      nil -> :not_found
      idx -> {:ok, Lens.make_lens(:columns) ~> Lens.idx(idx)}
    end
  end

  @spec pile_by_id(Board.t(), integer) :: lens_or_not_found
  def pile_by_id(board, id) do
    with {:ok, path} <- pile_path_by_id(board, id) do
      {:ok, compose_path(path)}
    end
  end

  @spec col_lens_by_path(path) :: Lens.t()
  def col_lens_by_path(path), do: compose_path(path, 2)

  @spec pile_lens_by_path(path) :: Lens.t()
  def pile_lens_by_path(path), do: compose_path(path, 4)

  @spec card_lens_by_path(path) :: Lens.t()
  def card_lens_by_path(path), do: compose_path(path, 6)

  @spec col_by_path(Board.t(), path) :: Column.t()
  def col_by_path(board, path), do: Focus.view(board, compose_path(path, 2))

  @spec pile_by_path(Board.t(), path) :: Pile.t()
  def pile_by_path(board, path), do: Focus.view(board, compose_path(path, 4))

  @spec card_by_path(Board.t(), path) :: Card.t()
  def card_by_path(board, path), do: Focus.view(board, compose_path(path, 6))

  @spec card_by_id(Board.t(), integer) :: lens_or_not_found
  def card_by_id(board, id) do
    with {:ok, path} <- card_path_by_id(board, id) do
      {:ok, compose_path(path)}
    end
  end

  @spec pile_path_by_id(Board.t(), integer) :: lens_path_or_not_found
  def pile_path_by_id(%Board{columns: columns}, id) do
    Enum.each(Enum.with_index(columns), fn {col, col_idx} ->
      Enum.each(Enum.with_index(col.piles), fn
        {%{id: ^id}, pile_idx} ->
          throw([
            Lens.make_lens(:columns),
            Lens.idx(col_idx),
            Lens.make_lens(:piles),
            Lens.idx(pile_idx)
          ])

        _ ->
          nil
      end)
    end)

    :not_found
  catch
    pile_path -> {:ok, pile_path}
  end

  # credo:disable-for-lines:10 Credo.Check.Refactor.Nesting
  @spec card_path_by_id(Board.t(), integer) :: lens_path_or_not_found
  def card_path_by_id(%Board{columns: columns}, id) do
    Enum.each(Enum.with_index(columns), fn {col, col_idx} ->
      Enum.each(Enum.with_index(col.piles), fn {pile, pile_idx} ->
        Enum.each(Enum.with_index(pile.cards), fn
          {%{id: ^id}, card_idx} ->
            throw([
              Lens.make_lens(:columns),
              Lens.idx(col_idx),
              Lens.make_lens(:piles),
              Lens.idx(pile_idx),
              Lens.make_lens(:cards),
              Lens.idx(card_idx)
            ])

          _ ->
            nil
        end)
      end)
    end)

    :not_found
  catch
    lens_path -> {:ok, lens_path}
  end

  # Create a lens from a path
  @spec compose_path(path, integer | nil) :: Lens.t()
  defp compose_path(path, count \\ nil) do
    [first | lenses] = if count, do: Enum.slice(path, 0, count), else: path

    Enum.reduce(lenses, first, fn lens, acc ->
      Focus.compose(acc, lens)
    end)
  end
end
