defmodule Lucidboard.Board do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Lucidboard.{BoardSettings, Column, User}

  @derive {Jason.Encoder, only: ~w(id title settings columns)a}

  schema "boards" do
    field(:title, :string)
    embeds_one(:settings, BoardSettings)
    has_many(:columns, Column)
    belongs_to(:user, User)

    timestamps()
  end

  @spec new(keyword) :: Board.t()
  def new(fields \\ []) do
    defaults = [settings: BoardSettings.new()]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title])
    |> cast_assoc(:columns)
    |> validate_required([:title])
  end
end
