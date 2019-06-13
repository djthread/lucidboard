defmodule Lucidboard.User do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{BoardRole, Card, Like, UserSettings}

  schema "users" do
    field(:name)
    field(:full_name)
    field(:avatar_url)
    embeds_one(:settings, UserSettings, on_replace: :delete)
    many_to_many(:cards_liked, Card, join_through: Like)
    has_many(:board_roles, BoardRole)

    timestamps()
  end

  @spec new(keyword) :: User.t()
  def new(fields \\ []) do
    defaults = [settings: UserSettings.new()]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :full_name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
