defmodule Lb2.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Card

  embedded_schema do
    field :title, :string
    embeds_many :cards, Card, on_replace: :delete
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title, :cards])
    |> validate_required([:title])
  end
end
