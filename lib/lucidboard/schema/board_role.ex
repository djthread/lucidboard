defmodule Lucidboard.BoardRole do
  @moduledoc "Schema for role a user has on a board"
  use Ecto.Schema
  alias Ecto.UUID
  alias Lucidboard.{Board, User}

  @primary_key {:id, :binary_id, autogenerate: false}
  # @derive {Jason.Encoder, only: ~w(id)a}

  schema "board_roles" do
    belongs_to(:board, Board)
    belongs_to(:user, User)
    field(:role, BoardRoleEnum)
  end

  @spec new(keyword) :: Like.t()
  def new(fields \\ []) do
    defaults = [id: UUID.generate()]
    struct(__MODULE__, Keyword.merge(defaults, fields))
  end
end
