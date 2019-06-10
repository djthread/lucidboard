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
      with num when not is_nil(num) <- attrs["votes_per_user"] || attrs[:votes_per_user] do
        String.to_integer(num)
      end

    IO.inspect({options, attrs})
    options
    |> cast(attrs, [:votes_per_user, :votes_per_user_per_card])
    |> validate_number(:votes_per_user_per_card,
      less_than: IO.inspect(per_user)
    )
  end
end
