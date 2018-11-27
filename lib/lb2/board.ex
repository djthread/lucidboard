defmodule Lb2.Board do
  @moduledoc """
  A context for board operations
  """
  # alias Lb2.Board.{Board, Card, Column}
  alias Ecto.Changeset
  alias Lb2.Board.{Action, Board, Column, Event, Util}
  alias Lb2.Repo
  import Ecto.Query

  @type action :: {atom, keyword}

  @spec act(Changeset.t(), action) ::
          {:ok, Changeset.t(), Event.t()} | {:error, String.t()}
  def act(changeset, {:set_column_title, args}) do
    with {:ok, [id, title]} <- grab(args, ~w/id title/a),
         {:ok, changeset} <- Util.column_set_title(changeset, id, title) do
      {:ok, changeset, event("has changed a column title to #{title}.")}
    end
  end

  def act(board, changeset, %{
        name: :reorder_columns,
        args: [column_ids: column_ids]
      }) do
    columns =
      Enum.sort(board.columns, fn c1, c2 ->
        c1_idx = Enum.find_index(column_ids, fn cid -> cid == c1.id end)
        c2_idx = Enum.find_index(column_ids, fn cid -> cid == c2.id end)
        c1_idx < c2_idx
      end)

    {:ok, change(changeset, %{columns: columns}),
     %Event{desc: "has rearranged the columns"}}
  end

  def act(_board, changeset, action) do
    IO.puts("act TBI: #{inspect(action)}")
    {:ok, changeset, %Event{desc: "i am an event #{inspect(action)}"}}
  end

  @doc "Get a board by its id"
  @spec by_id(integer) :: Board.t() | nil
  def by_id(id) do
    Repo.one(
      from(board in Board,
        where: board.id == ^id,
        left_join: columns in assoc(board, :columns),
        left_join: piles in assoc(columns, :piles),
        left_join: cards in assoc(piles, :cards),
        preload: [columns: {columns, piles: {piles, cards: cards}}]
      )
    )
  end

  @doc "Insert a board record"
  @spec insert(Board.t() | Ecto.Changeset.t(Board.t())) ::
          {:ok, Board.t()} | {:error, Ecto.Changeset.t(Board.t())}
  def insert(%Board{} = board), do: Repo.insert(board)

  @spec grab(keyword, [atom]) :: {:ok, [term]} | {:error, String.t()}
  defp grab(args, fields) do
    ret =
      fields
      |> Enum.reduce([], fn k, acc ->
        case Keyword.fetch(args, k) do
          {:ok, v} -> [v | acc]
          :error -> throw(k)
        end
      end)
      |> Enum.reverse()

    {:ok, ret}
  catch
    k -> {:error, "Missing argument #{k}"}
  end

  defp change(changeset, params) do
    params = Util.recursive_struct_to_map(params)
    Board.changeset(changeset, params)
  end

  defp event(msg) when is_binary(msg) do
    %Event{desc: msg}
  end

  defp event(keyword) when is_list(keyword) do
    struct(Event, keyword)
  end
end
