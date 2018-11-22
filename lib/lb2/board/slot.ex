defmodule Lb2.Board.Slot do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Card

  embedded_schema do
    embeds_many(:cards, Card, on_replace: :delete)
  end

  @doc false
  def changeset(slot, attrs) do
    slot
    |> cast(attrs, [:cards])
    |> validate_required([:cards])
  end
end
