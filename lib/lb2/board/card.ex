defmodule Lb2.Board.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:body, :string)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
