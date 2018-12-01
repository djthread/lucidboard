defmodule Lb2.GlassTest do
  use Lb2Web.ConnCase, async: true
  import Lb2.BoardFixtures
  alias Lb2.Twiddler.Glass

  test "get column lens by id" do
    board = board_fixture()
    {:ok, lens} = Glass.column_by_id(board, 2)
    assert "Col2" == Focus.view(lens, board).title
    assert :error == Glass.column_by_id(board, 99)
  end

  test "get card lens by id" do
    board = board_fixture()
    {:ok, lens} = Glass.card_by_id(board, 2)
    assert "whoa" == Focus.view(lens, board).body
    assert :error == Glass.card_by_id(board, 99)
  end

  test "get pile lens by id" do
    board = board_fixture()
    {:ok, lens} = Glass.pile_by_id(board, 2)
    assert 1 == length(Focus.view(lens, board).cards)
    assert :error == Glass.card_by_id(board, 99)
  end
end
