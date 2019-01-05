defmodule Lucidboard.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{CardSettings, Pile, User}

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "cards" do
    field(:pos, :integer)
    field(:body, :string)
    field(:locked, :boolean)
    # field(:locked_by, User)
    embeds_one(:settings, CardSettings)
    belongs_to(:pile, Pile, type: :binary_id)
    belongs_to(:user, User)
  end

  @spec new(keyword) :: Card.t()
  def new(fields \\ []) do
    defaults = [
      id: UUID.generate(),
      pos: 0,
      body: "",
      locked: false,
      settings: CardSettings.new()
    ]

    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
