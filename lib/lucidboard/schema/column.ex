defmodule Lucidboard.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{Board, Pile}

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "columns" do
    field(:title, :string)
    field(:pos, :integer)
    has_many(:piles, Pile)
    belongs_to(:board, Board)
  end

  @spec new(keyword) :: Column.t()
  def new(fields \\ []) do
    defaults = [id: UUID.generate(), pos: 0]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title])
    |> cast_assoc(:piles)
    |> validate_required([:title])
  end
end
