defmodule Lucidboard.Board.Settings do
  @moduledoc "Schema for a board settings"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:anonymous_cards, :boolean)
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:anonymous_cards])
  end
end
