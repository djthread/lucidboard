defmodule Lucidboard.BoardSettings do
  @moduledoc "Schema for a board's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:anonymous_cards, :boolean)
  end

  @spec new(keyword) :: BoardSettings.t()
  def new(fields \\ []) do
    defaults = [anonymous_cards: false]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:anonymous_cards])
  end
end
