defmodule Lb2.LiveBoardTest do
  use Lb2Web.ConnCase
  alias Lb2.Twiddler
  alias Lb2.Board.{Board, Column}

  test "db write" do
    {:ok, %Board{id: board_id, columns: [%Column{id: column_id}]}} =
      %Board{title: "Awesome", columns: [%Column{title: "foo", pos: 0}]}
      |> Twiddler.insert()

    {:ok, pid} = Lb2.start_live_board(board_id)

    action = {:set_column_title, id: column_id, title: "word"}
    Lb2.call(board_id, {:action, action})

    %Board{id: new_board_id, columns: [%Column{title: from_live_board}]} =
      Lb2.call(board_id, :board)

    assert "word" == from_live_board

    %Board{id: new_board_id, columns: [%Column{title: from_db}]} =
      Twiddler.by_id(board_id)

    assert "word" == from_db

    :ok = Lb2.stop_live_board(board_id)
  end
end
