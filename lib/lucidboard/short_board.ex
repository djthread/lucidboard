defmodule Lucidboard.ShortBoard do
  @moduledoc "Struct for a board in a listing (on the dashboard)"
  defstruct [:id, :title, :username, :updated_at]

  def from_board(board) do
    %__MODULE__{
      id: board.id,
      title: board.title,
      username: board.user.name,
      updated_at: board.updated_at
    }
  end
end
