defmodule Lb2.LiveBoardTest do
  use Lb2Web.ConnCase
  alias Lb2.Twiddler
  alias Lb2.Board.{Board, Column}

  test "basic LiveBoard lifecycle" do
    # Create a board record in the db
    {:ok, %Board{id: board_id, columns: [%Column{id: column_id}]}} =
      %Board{title: "Awesome", columns: [%Column{title: "foo", pos: 0}]}
      |> Twiddler.insert()

    # Start a liveboard based on it
    {:ok, _pid} = Lb2.start_live_board(board_id)

    # Set the column title
    action = {:set_column_title, id: column_id, title: "the new title"}
    Lb2.call(board_id, {:action, action})

    # Get the board state from the liveboard
    %Board{columns: [%Column{title: from_live_board}]} =
      Lb2.call(board_id, :board)

    # Ensure it's the new title and give the scribe long enough to persist
    assert "the new title" == from_live_board
    :timer.sleep(50)

    # Fetch it from the database
    %Board{columns: [%Column{title: from_db}]} = Twiddler.by_id(board_id)

    # Ensure the new title has persisted
    assert "the new title" == from_db

    :ok = Lb2.stop_live_board(board_id)
  end
end
