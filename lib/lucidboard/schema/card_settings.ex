defmodule Lucidboard.CardSettings do
  @moduledoc "Schema for a card's settings"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:color, :string)
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:color])
  end
end
