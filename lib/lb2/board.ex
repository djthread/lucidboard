defmodule Lb2.Board do
  @moduledoc """
  A context for board operations
  """
  # alias Lb2.Board.{Board, Card, Column}
  alias Ecto.Changeset
  alias Lb2.Board.{Action, Board, Event, Util}
  alias Lb2.Repo
  import Ecto.Query

  @spec act(Board.t(), Changeset.t(), Action.t()) ::
          {:ok, Changeset.t(), Event.t()} | {:error, String.t()}
  def act(board, changeset, %{name: :set_column_title, args: args}) do
    [id, title] = grab(args, ~w/id title/a)

    columns =
      Util.change_column(board.columns, id, fn col -> %{col | title: title} end)

    {:ok, change(changeset, %{columns: columns}),
     %Event{desc: "has changed a column title to #{title}"}}
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
  def by_id(id), do: Repo.one(from(Board, where: [id: ^id]))

  @doc "Insert a board record"
  @spec insert(Board.t() | Ecto.Changeset.t(Board.t())) ::
          {:ok, Board.t()} | {:error, Ecto.Changeset.t(Board.t())}
  def insert(%Board{} = board), do: Repo.insert(board)

  defp grab(args, fields) do
    fields
    |> Enum.reduce([], fn k, acc -> [Keyword.get(args, k) | acc] end)
    |> Enum.reverse()
  end

  defp change(changeset, params) do
    params = Util.recursive_struct_to_map(params)
    Board.changeset(changeset, params)
  end
end
