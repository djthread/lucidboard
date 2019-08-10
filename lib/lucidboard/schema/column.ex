defmodule Lucidboard.Column do
  @moduledoc "Schema for a board record"
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.UUID
  alias Lucidboard.{Board, Pile}

  @primary_key {:id, :binary_id, autogenerate: false}
  @derive {Jason.Encoder, only: ~w(id title pos piles)a}

  schema "columns" do
    field(:title, :string)
    field(:pos, :integer)
    has_many(:piles, Pile)
    belongs_to(:board, Board)
  end

  @spec new(keyword) :: Column.t()
  def new(fields \\ [], type \\ :struct) do
    defaults = [id: UUID.generate(), pos: 0, piles: []]
    data = Keyword.merge(defaults, fields)

    if type == :struct,
      do: struct(__MODULE__, data),
      else: Enum.into(data, %{})
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:id, :title, :pos, :board_id])
    |> cast_assoc(:piles)
    |> validate_required([:title])
  end
end
