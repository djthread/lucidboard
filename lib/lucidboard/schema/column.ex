defmodule Lucidboard.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{Board, Pile}

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "columns" do
    field(:title, :string)
    field(:pos, :integer)
    has_many(:piles, Pile)
    belongs_to(:board, Board)

    timestamps()
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title])
    |> cast_assoc(:piles)
    |> validate_required([:title])
  end
end
