defmodule Lucidboard.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.Pile

  schema "cards" do
    field(:pos, :integer)
    field(:body, :string)
    # field(:locked_by, User)
    belongs_to(:pile, Pile)
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
