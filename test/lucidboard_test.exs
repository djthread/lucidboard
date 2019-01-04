defmodule LucidboardTest do
  @moduledoc false
  use LucidboardWeb.ConnCase
  alias Lucidboard.Board
  alias Lucidboard.Twiddler

  test "Dynamic supervisor functions" do
    {:ok, board} = Twiddler.insert(%Board{title: "Awesome"})
    {:ok, pid} = Lucidboard.start_live_board(board.id)
    assert is_pid(pid)
    assert %{title: "Awesome"} = Lucidboard.call(board.id, :board)
    :ok = Lucidboard.stop_live_board(board.id)
    catch_exit(Lucidboard.call(board.id, :board))
    assert %{title: "Awesome"} = Twiddler.by_id(board.id)
  end
end
