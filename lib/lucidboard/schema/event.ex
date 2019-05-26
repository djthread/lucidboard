defmodule Lucidboard.Event do
  @moduledoc """
  Something that has occurred on a Lucidboard
  """
  use Ecto.Schema
  alias Lucidboard.{Board, User}

  schema "events" do
    belongs_to(:board, Board)
    belongs_to(:user, User)
    field(:desc)

    field(:inserted_at, :utc_datetime)
    field(:updated_at, :utc_datetime)
  end

  @spec new(keyword) :: Board.t()
  def new(fields \\ []) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    defaults = [
      inserted_at: now,
      updated_at: now
    ]

    struct(__MODULE__, Keyword.merge(defaults, fields))
  end
end
