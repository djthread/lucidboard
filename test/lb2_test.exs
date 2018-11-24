defmodule Lb2Test do
  use Lb2Web.ConnCase
  alias Lb2.Board, as: B
  alias Lb2.Board.Board

  test "Dynamic supervisor functions" do
    {:ok, pid, board} = Lb2.start_live_board(%Board{title: "Awesome"})
    assert is_pid(pid)
    assert %Board{} = board
    assert %{title: "Awesome"} = Lb2.call(board.id, :board)
    :ok = Lb2.stop_live_board(board.id)
    catch_exit(Lb2.call(board.id, :board))
    assert %{title: "Awesome"} = B.by_id(board.id)
  end
end
