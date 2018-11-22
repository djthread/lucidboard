defmodule Lb2.LiveBoardTest do
  use ExUnit.Case, async: true
  alias Lb2.LiveBoard

  test "Dynamic supervisor functions" do
    opts = [supervisor: TestSupervisorName]
    %{id: id} = %Board{title: "Awesome"} |> Repo.insert!()
    {:ok, pid} = LiveBoard.open(1, opts)
    assert is_pid(pid)
    :ok = LiveBoard.close(1, opts)
  end
end
