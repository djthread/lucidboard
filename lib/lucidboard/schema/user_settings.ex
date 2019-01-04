defmodule Lucidboard.UserSettings do
  @moduledoc "Schema for a user's settings"
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:theme, :string)
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:theme])
  end
end
