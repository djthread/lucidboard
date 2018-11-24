defmodule Lb2.Board do
  @moduledoc """
  A context for board operations
  """
  # alias Lb2.Board.{Board, Card, Column}
  alias Ecto.Changeset
  alias Lb2.Board.{Board, Event, Util}
  alias Lb2.Repo
  import Ecto.Query

  @spec act(Board.t(), Changeset.t(), Event.t()) ::
          {:ok, Changeset.t()} | {:error, String.t()}
  def act(board, changeset, %{action: :set_column_title, args: args}) do
    [id, title] = grab(args, ~w/id title/a)

    columns =
      board.columns
      |> Enum.reduce([], fn col, acc ->
        col = if id == col.id, do: %{col | title: title}, else: col
        [col | acc]
      end)
      |> Enum.reverse()
      |> Util.recursive_struct_to_map()

    # {:ok, Board.changeset(changeset, %{"columns" => []})}
    {:ok, Board.changeset(changeset, %{"columns" => columns})}
  end

  def act(_board, changeset, event) do
    IO.puts("act TBI: #{inspect(event)}")
    {:ok, changeset}
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
end
