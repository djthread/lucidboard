defmodule Lb2.Board.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lb2.Board.Pile

  schema "cards" do
    field(:pos, :integer)
    field(:body, :string)
    belongs_to(:pile, Pile)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
