defmodule Lb2.Board do
  @moduledoc """
  A context for the board
  """
  alias Lb2.Board.{Board, Card, Column}
  alias Lb2.Repo
  import Ecto.Query

  @doc "Get a board by its id"
  def by_id(id) do
    Repo.one(from Board, where: [id: ^id])
  end
end