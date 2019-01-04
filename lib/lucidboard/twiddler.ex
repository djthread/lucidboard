defmodule Lucidboard.Twiddler do
  @moduledoc """
  A context for board operations
  """
  import Ecto.Query
  alias Ecto.Changeset
  alias Lucidboard.{Board, Event}
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler.Actions

  @type action :: {atom, keyword | map}
  @type action_ok_or_error ::
          {:ok, Board.t(), function, Event.t()} | {:error, String.t()}

  @spec act(Board.t(), action) :: action_ok_or_error
  def act(%Board{} = board, {action_name, args}) when is_list(args) do
    act(board, {action_name, Enum.into(args, %{})})
  end

  def act(%Board{} = board, {action_name, args}) when is_atom(action_name) and is_map(args) do
    with true <- function_exported?(Actions, action_name, 2) || :no_action,
         {:ok, _, _, _} = res <- apply(Actions, action_name, [board, args]) do
      res
    else
      :no_action ->
        IO.puts("Action not implemented: #{inspect(action_name)}")
        {:ok, board, nil, nil}

      %Changeset{} = cs ->
        {:error, changeset_to_string(cs)}
    end
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

  defp changeset_to_string(%Changeset{valid?: false, errors: errs}) do
    errs
    |> Enum.map(fn {k, err} -> "#{k}: #{err}" end)
    |> Enum.join(", ")
    |> (fn msg -> "Error: #{msg}" end).()
  end
end
