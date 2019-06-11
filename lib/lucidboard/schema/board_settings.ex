defmodule Lucidboard.BoardSettings do
  @moduledoc "Schema for a board's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @default_likes_per_user 1
  @primary_key false
  @derive {Jason.Encoder, only: ~w(likes_per_user)a}

  embedded_schema do
    field(:likes_per_user, :integer)
    # field(:anonymous_cards, :boolean)
  end

  @spec new(keyword) :: BoardSettings.t()
  def new(fields \\ []) do
    defaults = [likes_per_user: @default_likes_per_user]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:likes_per_user])
  end
end
