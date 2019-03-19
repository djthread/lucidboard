defmodule Lucidboard.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{CardSettings, Like, Pile, User}

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, only: ~w(id pos body locked settings likes)a}

  schema "cards" do
    field(:pos, :integer)
    field(:body, :string)
    # field(:locked, :boolean)
    # field(:locked_by, User)
    embeds_one(:settings, CardSettings)
    belongs_to(:pile, Pile, type: :binary_id)
    belongs_to(:user, User)
    # many_to_many(:users_liked, User, join_through: Like)
    has_many(:likes, Like)
  end

  @spec new(keyword) :: Card.t()
  def new(fields \\ []) do
    defaults = [
      id: UUID.generate(),
      pos: 0,
      body: "",
      locked: false,
      settings: CardSettings.new(),
      likes: []
    ]

    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
    # |> cast_assoc(:users_liked)
  end

  @doc "Get the number of likes on a card"
  def like_count(%__MODULE__{likes: likes}) do
    length(likes)
  end
end
