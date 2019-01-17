defmodule Lucidboard.BoardSettings do
  @moduledoc "Schema for a board's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @default_votes_per_user 3

  @primary_key false

  embedded_schema do
    field(:votes_per_user, :integer)
    # field(:anonymous_cards, :boolean)
  end

  @spec new(keyword) :: BoardSettings.t()
  def new(fields \\ []) do
    defaults = [votes_per_user: @default_votes_per_user]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:votes_per_user])
  end
end
