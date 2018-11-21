defmodule Lb2.Board do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Column

  schema "boards" do
    field(:title, :string)
    embeds_many(:columns, Column, on_replace: :delete)

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :columns])
    |> validate_required([])
  end
end
