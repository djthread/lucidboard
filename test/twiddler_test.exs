defmodule Lb2.TwiddlerTest do
  use Lb2Web.ConnCase
  # use ExUnit.Case, async: true
  alias Ecto.Changeset
  alias Lb2.Board.Board
  alias Lb2.Twiddler
  import Lb2.BoardFixtures
  import Focus

  test "update card" do
    board = fixture()

    {:ok, new_board, cs, event} =
      Twiddler.act(board, {:update_card, id: 2, body: "OH YEAH"})

    assert true == cs.valid?
    assert %{body: "OH YEAH"} = Changeset.apply_changes(cs)

    assert "OH YEAH" ==
             Lens.make_lens(:columns)
             ~> Lens.idx(1)
             ~> Lens.make_lens(:piles)
             ~> Lens.idx(1)
             ~> Lens.make_lens(:cards)
             ~> Lens.idx(0)
             ~> Lens.make_lens(:body)
             |> Focus.view(new_board)
  end
end
