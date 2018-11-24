defmodule Lb2.Board.Pile do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Card

  embedded_schema do
    embeds_many(:cards, Card, on_replace: :delete)
  end

  @doc false
  def changeset(pile, attrs) do
    pile
    |> cast(attrs, [])
    |> cast_embed(:cards)
  end
end
