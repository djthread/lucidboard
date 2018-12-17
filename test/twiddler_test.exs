defmodule Lucidboard.TwiddlerTest do
  use LucidboardWeb.ConnCase
  alias Lucidboard.Twiddler
  import Lucidboard.BoardFixtures
  import Focus

  test "update card" do
    board = board_fixture()

    {:ok, new_board, _fun, _event} =
      Twiddler.act(board, {:update_card, id: 2, body: "OH YEAH"})

    card_lens =
      Lens.make_lens(:columns)
      ~> Lens.idx(2)
      ~> Lens.make_lens(:piles)
      ~> Lens.idx(0)
      ~> Lens.make_lens(:cards)
      ~> Lens.idx(0)

    assert "OH YEAH" == Focus.view(card_lens, new_board).body
  end

  test "set_column_title" do
    board = board_fixture()
    action = {:set_column_title, id: 2, title: "CHANGED IT"}

    {:ok, new_board, _cs, event} = Twiddler.act(board, action)

    assert "has changed a column title to CHANGED IT." == event.desc

    assert "CHANGED IT" ==
             new_board |> Map.get(:columns) |> Enum.at(1) |> Map.get(:title)
  end

  test "move_column" do
    titles = fn columns -> Enum.map(columns, & &1.title) end
    board = board_fixture()

    # Baseline
    ~w(Col1 Col2 Col3) = titles.(board.columns)

    action = {:move_column, id: 3, new_pos: 0}

    {:ok, new_board, _cs, event} = Twiddler.act(board, action)

    assert "has moved the `Col3` column." == event.desc
    assert ~w(Col3 Col1 Col2) == titles.(new_board.columns)
  end
end
