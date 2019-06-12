defmodule Lucidboard.Twiddler.Actions do
  @moduledoc """
  Core logic responsible for handling different lucidboard changes.
  """
  alias Ecto.Changeset
  alias Lucidboard.{Board, Card, Column, Event}
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler
  alias Lucidboard.Twiddler.{Glass, Op, QueryBuilder}
  import Ecto.Query

  @spec update_board(Board.t(), map) :: Twiddler.action_ok_or_error()
  def update_board(board, args) do
    with %Changeset{valid?: true} = cs <- Board.changeset(board, args),
         new_board <- Changeset.apply_changes(cs) do
      {:ok, new_board, fn -> Repo.update(cs) end, %{},
       event("has updated the board settings.")}
    end
  end

  @spec add_column(Board.t(), map) :: Twiddler.action_ok_or_error()
  def add_column(board, args) do
    args =
      args
      |> Enum.into([])
      |> Keyword.merge(board_id: board.id, pos: length(board.columns))
      |> Column.new()
      |> Map.from_struct()

    with %Changeset{valid?: true} = cs <- Column.changeset(%Column{}, args),
         new_col <- Changeset.apply_changes(cs) do
      new_board = %{board | columns: List.insert_at(board.columns, -1, new_col)}

      {:ok, new_board, fn -> Repo.insert(cs) end, %{},
       event("has created the `#{new_col.title}` column.")}
    end
  end

  @spec update_column(Board.t(), map) :: Twiddler.action_ok_or_error()
  def update_column(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, lens} <- Glass.column_by_id(board, id),
         %Changeset{valid?: true} = cs <-
           lens |> Focus.view(board) |> Column.changeset(args),
         new_col <- Changeset.apply_changes(cs) do
      {:ok, Focus.set(lens, board, new_col), fn -> Repo.update(cs) end, %{},
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
       fn -> Repo.update(cs) end, %{}, event("has changed card text.")}
    end
  end

  @spec delete_card(Board.t(), map) :: Twiddler.action_ok_or_error()
  def delete_card(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, card_path} <- Glass.card_path_by_id(board, id),
         {:ok, new_board, card, tx_fn} <- Op.cut_card(board, card_path) do
      del_card = fn -> QueryBuilder.delete_card(card) end
      {:ok, new_board, [del_card, tx_fn], %{}, event("has deleted a card.")}
    end
  end

  def delete_column(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, lens} <- Glass.column_by_id(board, id) do
      column = Focus.view(lens, board)
      new_columns = Op.remove_item(board.columns, column.pos)

      tx_fn = fn ->
        q = from(c in Column, where: c.pos > ^column.pos)
        Repo.update_all(q, inc: [pos: -1])
        Repo.delete(column)
      end

      {:ok, %{board | columns: new_columns}, tx_fn, %{},
       event("has deleted the `#{column.title}` column.")}
    end
  end

  @spec add_and_lock_card(Board.t(), map) :: Twiddler.action_ok_or_error()
  def add_and_lock_card(board, args) do
    with [col_id, user_id] <- grab(args, [:col_id, :user_id]),
         {:ok, col_lens} <- Glass.column_by_id(board, col_id),
         {:ok, built_col, loaded_col, meta} <-
           Op.add_locked_card(Focus.view(col_lens, board), user_id) do
      tx_fn = fn -> built_col.piles |> List.last() |> Repo.insert() end
      new_board = Focus.set(col_lens, board, loaded_col)
      {:ok, new_board, tx_fn, meta, event("has created a card.")}
    end
  end

  @spec move_column(Board.t(), map) :: Twiddler.action_ok_or_error()
  def move_column(board, args) do
    queryable = from(c in Column, where: c.board_id == ^board.id)

    with [id, new_pos] <- grab(args, ~w/id pos/a),
         pos <- Enum.find(board.columns, fn c -> c.id == id end).pos,
         {:ok, col, new_cols} <- Op.move_item(board.columns, pos, new_pos),
         tx_fn <- QueryBuilder.move_item(queryable, id, pos, new_pos) do
      new_board = %{board | columns: new_cols}

      {:ok, new_board, tx_fn, %{},
       event("has moved the `#{col.title}` column.")}
    end
  end

  def move_column_up(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, col} <- Op.column_by_id(board, id),
         true <- col.pos > 0 || :noop do
      pos = col.pos - 1
      move_column(board, %{id: id, pos: pos})
    end
  end

  def move_column_down(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, col} <- Op.column_by_id(board, id),
         true <- col.pos < length(board.columns) - 1 || :noop do
      pos = col.pos + 1
      move_column(board, %{id: id, pos: pos})
    end
  end

  @spec move_pile_to_junction(Board.t(), map) :: Twiddler.action_ok_or_error()
  def move_pile_to_junction(board, args) do
    with [id, col_id, pos] <- grab(args, ~w/id col_id pos/a),
         {:ok, pile_path} <- Glass.pile_path_by_id(board, id),
         {:ok, dest_col_lens} <- Glass.column_by_id(board, col_id),
         {:ok, new_board, pile, reflow_fn} <- Op.cut_pile(board, pile_path),
         actual_pos <- Op.calculate_pile_pos(board, pile_path, col_id, pos),
         {:ok, new_board2, readd_fn} <-
           Op.add_pile_to_column(new_board, pile, dest_col_lens, actual_pos) do
      {:ok, new_board2, [reflow_fn, readd_fn], %{}, event("has moved a pile.")}
    end
  end

  # Moves a card to an empty space in a column, creating a new, 1-card pile
  def move_card_to_junction(board, args) do
    with [id, col_id, pos] <- grab(args, ~w/id col_id pos/a),
         {:ok, card_path} <- Glass.card_path_by_id(board, id),
         {:ok, col_lens} <- Glass.column_by_id(board, col_id),
         {:ok, new_board, card, cut_fn} <- Op.cut_card(board, card_path),
         actual_pos <- Op.calculate_pile_pos(board, card_path, col_id, pos),
         {:ok, new_board2, paste_fn} <-
           Op.add_card_to_column(new_board, card, col_lens, actual_pos) do
      {:ok, new_board2, [paste_fn, cut_fn], %{}, event("has moved a card.")}
    end
  end

  def move_card_to_pile(board, args) do
    with [id, pile_id] <- grab(args, ~w/id pile_id/a),
         {:ok, card_path} <- Glass.card_path_by_id(board, id),
         {:ok, new_board, card, cut_fn} <- Op.cut_card(board, card_path),
         true <- pile_id != card.pile_id || :noop,
         {:ok, pile_lens} <- Glass.pile_by_id(new_board, pile_id),
         {:ok, new_board2, add_fn} <-
           Op.add_card_to_pile(new_board, card, pile_lens) do
      {:ok, new_board2, [add_fn, cut_fn], %{}, event("has moved a card.")}
    end
  end

  def flip_pile(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, pile_lens} <- Glass.pile_by_id(board, id),
         {:ok, new_board, tx_fn} <- Op.flip_pile(board, pile_lens) do
      {:ok, new_board, tx_fn, %{}, nil}
    end
  end

  def unflip_pile(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, pile_lens} <- Glass.pile_by_id(board, id),
         {:ok, new_board, tx_fn} <- Op.unflip_pile(board, pile_lens) do
      {:ok, new_board, tx_fn, %{}, nil}
    end
  end

  @spec like(Board.t(), map) :: Twiddler.action_ok_or_error()
  def like(board, args) do
    with [id, user] <- grab(args, ~w/id user/a),
         {:ok, card_lens} <- Glass.card_by_id(board, id),
         card <- Focus.view(card_lens, board),
         true <- Op.user_can_like(board, user, card) || :noop do
      card = Focus.view(card_lens, board)
      {:ok, built_like, new_card} = Op.like(card, user)
      tx_fn = fn -> Repo.insert!(built_like) end
      new_board = Focus.set(card_lens, board, new_card)
      {:ok, new_board, tx_fn, %{}, event("liked a card.")}
    end
  end

  @spec unlike(Board.t(), map) :: Twiddler.action_ok_or_error()
  def unlike(board, args) do
    with [id, user] <- grab(args, ~w/id user/a),
         {:ok, card_lens} <- Glass.card_by_id(board, id) do
      card = Focus.view(card_lens, board)
      {:ok, like_to_delete, new_card} = Op.unlike(card, user)
      tx_fn = fn -> Repo.delete!(like_to_delete) end
      new_board = Focus.set(card_lens, board, new_card)
      {:ok, new_board, tx_fn, %{}, event("unliked a card.")}
    end
  end

  def sortby_likes(board, args) do
    with [id] <- grab(args, [:id]),
         {:ok, col_lens} <- Glass.column_by_id(board, id),
         column <- Focus.view(col_lens, board) do
      {sorted_piles, tx_fn} =
        column
        |> Map.get(:piles)
        |> Enum.sort(fn p1, p2 -> Op.likes(p1) > Op.likes(p2) end)
        |> Op.renumber_piles()

      new_board = Focus.set(col_lens, board, %{column | piles: sorted_piles})

      {:ok, new_board, tx_fn, %{},
       event("Sorted `#{column.title}` column by likes.")}
    end
  end

  # Ex. Given `%{a: 1}` and `[:a, :b?]`, return `[1, nil]`. The trailing `?`
  # indicates that the field is required. Without it, an error will be returned
  # if the key is not found in args.
  @spec grab(map, [atom]) :: [term] | {:error, String.t()}
  defp grab(args, fields) when is_map(args) and is_list(fields) do
    args = Enum.into(args, %{}, fn {k, v} -> {to_string(k), v} end)

    fields
    |> Enum.reduce([], fn k, acc ->
      k = to_string(k)
      key = String.trim_trailing(k, "?")
      val = Map.get(args, key)
      optional? = key != k

      if is_nil(val) and not optional?,
        do: throw(key),
        else: [val | acc]
    end)
    |> Enum.reverse()
  catch
    k -> {:error, "Missing required argument: #{k}"}
  end

  defp event(msg) when is_binary(msg) do
    Event.new(desc: msg)
  end

  # defp event(msg, keyword) when is_binary(msg) and is_list(keyword) do
  #   struct(Event, Keyword.merge(keyword, desc: msg))
  # end
end
