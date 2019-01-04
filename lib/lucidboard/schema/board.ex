defmodule Lucidboard.Board do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{Column, Settings}

  schema "boards" do
    field(:title, :string)
    embeds_one(:settings, Settings)
    has_many(:columns, Column)

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title])
    |> cast_assoc(:columns)
    |> validate_required([:title])
  end
end
