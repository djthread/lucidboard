defmodule Lb2.Board.Card do
  use Ecto.Schema
  import Ecto.Changeset


  schema "cards" do
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:content])
    |> validate_required([])
  end
end
