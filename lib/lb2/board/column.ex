defmodule Lb2.Board.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Pile

  embedded_schema do
    field(:title, :string)
    embeds_many(:piles, Pile, on_replace: :delete)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title])
    |> cast_embed(:piles)
    |> validate_required([:title])
  end
end
