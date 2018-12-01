defmodule Lb2.Twiddler do
  @moduledoc """
  A context for board operations
  """
  alias Ecto.Changeset
  alias Lb2.Board.{Board, Card, Column, Event}
  alias Lb2.Repo
  alias Lb2.Twiddler.{Glass, Op}
  import Ecto.Query
  import Focus

  @type action :: {atom, keyword}

  @spec act(Board.t(), action) ::
          {:ok, Board.t(), Changeset.t(), Event.t()} | {:error, String.t()}
  def act(board, {:set_column_title, args}) do
    with [col_id, title] <- grab(args, ~w/id title/a),
         {:ok, lens} <- Glass.column_by_id(board, col_id),
         %Changeset{valid?: true} = cs <-
           lens |> Focus.view(board) |> Column.changeset(%{title: title}) do
      new_board = Focus.set(lens, board, Changeset.apply_changes(cs))
      {:ok, new_board, cs, event("has changed a column title to #{title}.")}
    end
  end

  def act(board, {:update_card, args}) do
    with {:ok, id} <- Keyword.fetch(args, :id),
         {:ok, lens} <- Glass.card_by_id(board, id) do
      card = Focus.view(lens, board)
      cs = Card.changeset(card, Enum.into(args, %{}))
      new_board = Focus.set(lens, board, Changeset.apply_changes(cs))
      {:ok, new_board, cs, event("has changed card text.")}
    end
  end

  def act(board, {:move_pile, args}) do
    with [col_id, id, new_pos] <- grab(args, ~w/col_id id new_pos/a),
         {:ok, col_lens} <- Glass.column_by_id(board, col_id) do
      column = Focus.view(col_lens, board)
      {pile, piles} = Op.move_items(column.piles, id, new_pos)
      # cs = Card.changeset(card, Enum.into(args, %{}))
      piles_lens = col_lens ~> Lens.make_lens(:piles)
      new_board = Focus.set(piles_lens, board, piles)

      wat = if length(pile.cards) > 1, do: "a pile", else: "a card"

      {:ok, new_board, nil, event("has moved #{wat}.")}
    end
  end

  def act(board, {:move_column, args}) do
    with [id, new_pos] <- grab(args, ~w/id new_pos/a),
         {col, new_cols} <- Op.move_items(board.columns, id, new_pos) do
      new_board = %{board | columns: new_cols}
      {:ok, new_board, nil, event("has moved the `#{col.title}` column.")}
    end
  end

  # def act(board, changeset, %{
  #       name: :reorder_columns,
  #       args: [column_ids: column_ids]
  #     }) do
  #   columns =
  #     Enum.sort(board.columns, fn c1, c2 ->
  #       c1_idx = Enum.find_index(column_ids, fn cid -> cid == c1.id end)
  #       c2_idx = Enum.find_index(column_ids, fn cid -> cid == c2.id end)
  #       c1_idx < c2_idx
  #     end)

  #   {:ok, change(changeset, %{columns: columns}),
  #    %Event{desc: "has rearranged the columns"}}
  # end

  def act(board, action) do
    IO.puts("act TBI: #{inspect(action)}")
    {:ok, board, nil, event("i am an event #{inspect(action)}")}
  end

  @doc "Get a board by its id"
  @spec by_id(integer) :: Board.t() | nil
  def by_id(id) do
    board =
      Repo.one(
        from(board in Board,
          where: board.id == ^id,
          left_join: columns in assoc(board, :columns),
          left_join: piles in assoc(columns, :piles),
          left_join: cards in assoc(piles, :cards),
          preload: [columns: {columns, piles: {piles, cards: cards}}]
        )
      )

    if board, do: sort_board(board), else: nil
  end

  @doc "Sort all the columns, piles, and cards by their `:pos` fields"
  @spec sort_board(Board.t()) :: Board.t()
  def sort_board(%Board{} = board) do
    cols =
      Enum.reduce(board.columns, [], fn col, acc_cols ->
        piles =
          Enum.reduce(col.piles, [], fn pile, acc_piles ->
            cards = Enum.sort(pile.cards, &(&1.pos < &2.pos))
            [%{pile | cards: cards} | acc_piles]
          end)

        piles = Enum.sort(piles, &(&1.pos < &2.pos))
        [%{col | piles: piles} | acc_cols]
      end)

    cols = Enum.sort(cols, &(&1.pos < &2.pos))
    %{board | columns: cols}
  end

  @doc "Insert a board record"
  @spec insert(Board.t() | Ecto.Changeset.t(Board.t())) ::
          {:ok, Board.t()} | {:error, Ecto.Changeset.t(Board.t())}
  def insert(%Board{} = board), do: Repo.insert(board)

  @spec grab(keyword, [atom]) :: [term] | {:error, String.t()}
  defp grab(args, fields) do
    fields
    |> Enum.reduce([], fn k, acc ->
      case Keyword.fetch(args, k) do
        {:ok, v} -> [v | acc]
        :error -> throw(k)
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
