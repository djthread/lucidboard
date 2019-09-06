defmodule Lucidboard.BoardSettings do
  @moduledoc "Schema for a board's settings"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  # @derive {Jason.Encoder, only: ~w(likes_per_user likes_per_user_per_card)a}

  embedded_schema do
    field(:likes_per_user, :integer, default: 3)
    field(:likes_per_user_per_card, :integer, default: 3)
    field(:access, :string, default: "open")
    field(:anonymous, :boolean, default: true)
  end

  @spec new(keyword) :: BoardSettings.t()
  def new(fields \\ [], type \\ :struct) do
    if type == :struct,
      do: struct(__MODULE__, fields),
      else: Enum.into(fields, %{})
  end

  @doc false
  def changeset(settings, attrs \\ %{}) do
    per_user =
      case attrs["likes_per_user"] || settings.likes_per_user do
        str when is_binary(str) -> String.to_integer(str)
        int when is_integer(int) -> int
      end

    settings
    |> cast(attrs, [:likes_per_user, :likes_per_user_per_card, :access])
    |> validate_number(:likes_per_user_per_card, less_than_or_equal_to: per_user)
    |> validate_access(:access)
  end

  def validate_access(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, access ->
      case access in ["open", "private"] do
        true -> []
        false -> [{field, options[:message] || "Unexpected Access Value"}]
      end
    end)
  end
end
