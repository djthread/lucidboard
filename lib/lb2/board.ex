defmodule Lb2.Board do
  @moduledoc """
  A context for board operations
  """
  # alias Lb2.Board.{Board, Card, Column}
  alias Lb2.Board.Board
  alias Lb2.Repo
  import Ecto.Query

  @type msg :: :board

  @spec act(Board.t(), msg) :: {:ok, Board.t()}
  def act(board, :board) do
    {:ok, board}
  end

  def act(board, msg) do
    IO.puts("act TBI: #{inspect(msg)}")
    {:ok, board}
  end

  @doc "Get a board by its id"
  @spec by_id(integer) :: Board.t() | nil
  def by_id(id), do: Repo.one(from(Board, where: [id: ^id]))

  @doc "Insert a board record"
  @spec insert(Board.t() | Ecto.Changeset.t(Board.t())) ::
          {:ok, Board.t()} | {:error, Ecto.Changeset.t(Board.t())}
  def insert(%Board{} = board), do: Repo.insert(board)
end
