defmodule Lucidboard.LiveBoardTest do
  use LucidboardWeb.ConnCase
  alias Lucidboard.Twiddler
  alias Lucidboard.Board.{Board, Column}

  test "basic LiveBoard lifecycle" do
    # Create a board record in the db
    {:ok, %Board{id: board_id, columns: [%Column{id: column_id}]}} =
      %Board{title: "Awesome", columns: [%Column{title: "foo", pos: 0}]}
      |> Twiddler.insert()

    # Start a liveboard based on it
    {:ok, _pid} = Lucidboard.start_live_board(board_id)

    # Set the column title
    action = {:update_column, id: column_id, title: "the new title"}
    Lucidboard.call(board_id, {:action, action})

    # Get the board state from the liveboard
    %Board{columns: [%Column{title: from_live_board}]} =
      Lucidboard.call(board_id, :board)

    # Ensure it's the new title
    assert "the new title" == from_live_board

    # Give the scribe long enough to save and fetch it from the database
    :timer.sleep(50)
    %Board{columns: [%Column{title: from_db}]} = Twiddler.by_id(board_id)

    # Ensure the new title has persisted
    assert "the new title" == from_db

    :ok = Lucidboard.stop_live_board(board_id)
  end
end
