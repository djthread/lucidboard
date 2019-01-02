defmodule Lucidboard.Twiddler.Actions do
  @moduledoc """
  Core logic responsible for handling different lucidboard changes.
  """
  alias Ecto.Changeset
  alias Lucidboard.Board.{Board, Card, Column, Event, Pile}
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler
  alias Lucidboard.Twiddler.{Glass, Op, QueryBuilder}
  import Ecto.Query

  @spec update_board(Board.t(), map) :: Twiddler.action_ok_or_error()
  def update_board(board, args) do
    with %Changeset{valid?: true} = cs <- Board.changeset(board, args),
         new_board <- Changeset.apply_changes(cs) do
      {:ok, new_board, fn -> Repo.update(cs) end,
       event("has updated the board settings.")}
    end
  end

  @spec update_column(Board.t(), map) :: Twiddler.action_ok_or_error()
  def update_column(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, lens} <- Glass.column_by_id(board, id),
         %Changeset{valid?: true} = cs <-
           lens |> Focus.view(board) |> Column.changeset(args),
         new_col <- Changeset.apply_changes(cs) do
      {:ok, Focus.set(lens, board, new_col), fn -> Repo.update(cs) end,
       event("has updated the `#{new_col.title}` column.")}
    else
      :not_found -> {:error, "Column not found"}
    end
  end

  @spec update_card(Board.t(), map) :: Twiddler.action_ok_or_error()
  def update_card(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, lens} <- Glass.card_by_id(board, id),
         %Changeset{valid?: true} = cs <-
           lens |> Focus.view(board) |> Card.changeset(args) do
      {:ok, Focus.set(lens, board, Changeset.apply_changes(cs)),
       fn -> Repo.update(cs) end, event("has changed card text.")}
    end
  end

  @spec move_column(Board.t(), map) :: Twiddler.action_ok_or_error()
  def move_column(board, args) do
    queryable = from(c in Column, where: c.board_id == ^board.id)

    with [id, new_pos] <- grab(args, ~w/id new_pos/a),
         pos <- Enum.find(board.columns, fn c -> c.id == id end).pos,
         {:ok, col, new_cols} <- Op.move_item(board.columns, pos, new_pos),
         tx_fn <- QueryBuilder.move_item(queryable, id, pos, new_pos) do
      new_board = %{board | columns: new_cols}
      {:ok, new_board, tx_fn, event("has moved the `#{col.title}` column.")}
    end
  end

  @spec move_pile(Board.t(), map) :: Twiddler.action_ok_or_error()
  def move_pile(board, args) do
    with [id, col_id, new_pos] <- grab(args, ~w/id col_id new_pos/a),
         {:ok, col_lens} <- Glass.column_by_id(board, col_id),
         col <- Focus.view(col_lens, board),
         {:ok, pos} <- Op.find_pos_by_id(col.piles, id),
         {:ok, pile, new_piles} <- Op.move_item(col.piles, pos, new_pos),
         queryable <- from(p in Pile, where: p.column_id == ^col_id),
         tx_fn <- QueryBuilder.move_item(queryable, id, pos, new_pos) do
      new_board = Focus.set(col_lens, board, %{col | piles: new_piles})
      what = if pile.cards == 1, do: "card", else: "pile"
      {:ok, new_board, tx_fn, event("has moved a #{what}.")}
    end
  end

  @spec grab(map, [atom]) :: [term] | {:error, String.t()}
  defp grab(args, fields) when is_map(args) and is_list(fields) do
    fields
    |> Enum.reduce([], fn k, acc ->
      case Map.get(args, to_string(k)) || Map.get(args, k) do
        nil -> throw(k)
        v -> [v | acc]
      end
    end)
    |> Enum.reverse()
  catch
    k -> {:error, "Missing argument #{k}"}
  end

  defp event(msg) when is_binary(msg) do
    %Event{desc: msg}
  end

  # defp event(msg, keyword) when is_binary(msg) and is_list(keyword) do
  #   struct(Event, Keyword.merge(keyword, desc: msg))
  # end
end
