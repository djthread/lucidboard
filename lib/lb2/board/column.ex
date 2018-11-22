defmodule Lb2.Board.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Slot

  embedded_schema do
    field(:title, :string)
    embeds_many(:slots, Slot, on_replace: :delete)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title, :cards])
    |> validate_required([:title])
  end
end
