defmodule Lucidboard.Like do
  @moduledoc "Schema for a user's like on a card"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{Card, User}

  @fields [:user_id, :card_id]
  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, only: ~w(id)a}

  schema "likes" do
    belongs_to(:card, Card, type: :binary_id)
    belongs_to(:user, User)
    # field(:count, :integer)
  end

  @spec new(keyword) :: Like.t()
  def new(fields \\ []) do
    defaults = [id: UUID.generate()]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  def changeset(like, attrs) do
    like
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> foreign_key_constraint(:card_id)
    |> foreign_key_constraint(:user_id)
  end
end
