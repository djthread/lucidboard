defmodule Lb2.Board.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string
    field :columns, {:array, :integer}, cards: []

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :columns])
    |> validate_required([])
  end
end
