defmodule Lucidboard.User do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{Pile, UserSettings}

  schema "users" do
    field(:pos, :integer)
    field(:body, :string)
    # field(:locked_by, User)
    embeds_one(:settings, UserSettings)
    belongs_to(:pile, Pile)

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
