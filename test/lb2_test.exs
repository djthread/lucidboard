defmodule Lb2Test do
  use Lb2Web.ConnCase
  alias Lb2.Board.Board
  alias Lb2.Twiddler

  test "Dynamic supervisor functions" do
    {:ok, board} = Twiddler.insert(%Board{title: "Awesome"})
    {:ok, pid} = Lb2.start_live_board(board.id)
    assert is_pid(pid)
    assert %{title: "Awesome"} = Lb2.call(board.id, :board)
    :ok = Lb2.stop_live_board(board.id)
    catch_exit(Lb2.call(board.id, :board))
    assert %{title: "Awesome"} = Twiddler.by_id(board.id)
  end
end
