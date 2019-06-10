defimpl Inspect, for: Lucidboard.Board do
  import Inspect.Algebra

  def inspect(_dict, _opts) do
    concat(["#Board<>"])
  end
end

defmodule Lucidboard.Board do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{BoardOptions, Column, Event, User}

  @derive {Jason.Encoder, only: ~w(id title settings columns)a}

  schema "boards" do
    field(:title, :string)
    embeds_one(:options, BoardOptions, on_replace: :delete)
    has_many(:columns, Column)
    has_many(:events, Event)
    belongs_to(:user, User)

    field(:inserted_at, :utc_datetime)
    field(:updated_at, :utc_datetime)
  end

  @spec new(keyword) :: Board.t()
  def new(fields \\ []) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    defaults = [
      options: BoardOptions.new(),
      inserted_at: now,
      updated_at: now
    ]

    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title])
    |> cast_embed(:options)
    |> cast_assoc(:columns)
    |> validate_required([:title])
  end
end
