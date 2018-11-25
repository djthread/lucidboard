defmodule Lb2.Board.Pile do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Card

  # @primary_key {:id, :binary_id, autogenerate: true}
  @primary_key false

  embedded_schema do
    field(:id, :binary)
    embeds_many(:cards, Card, on_replace: :delete)
  end

  def create(params) do
    uuid = [id: Ecto.UUID.generate()]
    struct(__MODULE__, uuid ++ params)
  end

  @doc false
  def changeset(pile, attrs) do
    pile
    |> cast(attrs, [])
    |> cast_embed(:cards)
  end
end
