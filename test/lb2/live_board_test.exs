defmodule Lb2.LiveBoardTest do
  use ExUnit.Case, async: true
  alias Lb2.Board.Board
  alias Lb2.LiveBoard
  alias Lb2.Repo

  test "Dynamic supervisor functions" do
    opts = [supervisor: TestSupervisorName]
    %{id: id} = %Board{title: "Awesome"} |> Repo.insert!()
    {:ok, pid} = LiveBoard.open(id, opts)
    assert is_pid(pid)
    :ok = LiveBoard.close(id, opts)
  end
end
