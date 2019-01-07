defmodule Lucidboard.CardSettings do
  @moduledoc "Schema for a card's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field(:color, :string)
  end

  @spec new(keyword) :: CardSettings.t()
  def new(fields \\ []) do
    defaults = [color: "none"]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:color])
  end
end
