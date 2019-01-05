defmodule Lucidboard.UserSettings do
  @moduledoc "Schema for a user's settings"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:theme, :string)
  end

  @spec new(keyword) :: UserSettings.t()
  def new(fields \\ []) do
    defaults = [theme: "default"]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:theme])
  end
end
