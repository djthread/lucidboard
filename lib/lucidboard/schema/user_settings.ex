defmodule Lucidboard.UserSettings do
  @moduledoc "Schema for a user's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @default_theme Application.get_env(:lucidboard, :default_theme)

  embedded_schema do
    field(:theme, :string, default: @default_theme)
  end

  @spec new(keyword) :: UserSettings.t()
  def new(fields \\ []) do
    struct(__MODULE__, fields)
  end

  @doc false
  def changeset(settings, attrs) do
    settings
    |> cast(attrs, [:theme])
  end
end
