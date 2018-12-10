defmodule Lucidboard.Board.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.Board.{Board, Pile}

  schema "columns" do
    field(:title, :string)
    field(:pos, :integer)
    has_many(:piles, Pile)
    belongs_to(:board, Board)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title])
    |> cast_assoc(:piles)
    |> validate_required([:title])
  end
end
