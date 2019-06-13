defmodule Lucidboard.BoardSettings do
  @moduledoc "Schema for a board's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  # @derive {Jason.Encoder, only: ~w(likes_per_user likes_per_user_per_card)a}

  embedded_schema do
    field(:likes_per_user, :integer, default: 3)
    field(:likes_per_user_per_card, :integer, default: 3)
    # field(:anonymous_cards, :boolean)
  end

  @spec new(keyword) :: BoardSettings.t()
  def new(fields \\ []) do
    struct(__MODULE__, fields)
  end

  @doc false
  def changeset(settings, attrs \\ %{}) do
    settings
    |> cast(attrs, [:likes_per_user, :likes_per_user_per_card])
  end
end
