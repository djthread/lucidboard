defmodule Lucidboard.Pile do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{Card, Column}

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "piles" do
    field(:pos, :integer)
    has_many(:cards, Card)
    belongs_to(:column, Column, type: :binary_id)

    timestamps()
  end

  @spec new(keyword) :: Pile.t()
  def new(fields \\ []) do
    defaults = [id: UUID.generate(), pos: 0]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(pile, attrs) do
    pile
    |> cast(attrs, [])
    |> cast_assoc(:cards)
  end
end
