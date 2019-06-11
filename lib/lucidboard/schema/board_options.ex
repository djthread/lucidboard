defmodule Lucidboard.BoardOptions do
  @moduledoc "Schema for a board's options"
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  # @derive {Jason.Encoder, only: ~w(votes_per_user votes_per_user_per_card)a}

  embedded_schema do
    field(:votes_per_user, :integer, default: 3)
    field(:votes_per_user_per_card, :integer, default: 3)
    # field(:anonymous_cards, :boolean)
  end

  @spec new(keyword) :: BoardOptions.t()
  def new(fields \\ []) do
    struct(__MODULE__, fields)
  end

  @doc false
  def changeset(options, attrs) do
    per_user =
      case attrs["votes_per_user"] || options.votes_per_user do
        str when is_binary(str) -> String.to_integer(str)
        int when is_integer(int) -> int
      end

    options
    |> cast(attrs, [:votes_per_user, :votes_per_user_per_card])
    |> validate_number(:votes_per_user_per_card, less_than: per_user)
  end
end
