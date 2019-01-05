defmodule Lucidboard.Card do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{CardSettings, Pile, User}

  schema "cards" do
    field(:pos, :integer)
    field(:body, :string)
    field(:locked, :boolean)
    # field(:locked_by, User)
    embeds_one(:settings, CardSettings)
    belongs_to(:pile, Pile)
    belongs_to(:user, User)

    timestamps()
  end

  @spec new(keyword) :: Card.t()
  def new(fields \\ []) do
    defaults = [pos: 0, body: "", locked: false, settings: CardSettings.new()]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
