defmodule Lucidboard.ShortBoard do
  @moduledoc "Struct for a board in a listing (on the dashboard)"
  alias Lucidboard.{Event, TimeMachine}

  @type t :: %__MODULE__{
          id: integer,
          title: String.t(),
          username: String.t(),
          updated_at: DateTime.t(),
          last_event: Event.t()
        }

  defstruct [:id, :title, :username, :inserted_at, :updated_at, :last_event]

  def from_board(board) do
    last_event = board.id |> TimeMachine.events(size: 1) |> List.first()

    %__MODULE__{
      id: board.id,
      title: board.title,
      username: board.user.name,
      inserted_at: board.inserted_at,
      updated_at: board.updated_at,
      last_event: last_event
    }
  end
end
