defmodule Lb2.Board.Column do
  use Ecto.Schema
  import Ecto.Changeset


  schema "columns" do
    field :name, :string
    field :cards, {:array, :integer}, default: []

    timestamps()
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:name, :cards])
    |> validate_required([])
  end
end
