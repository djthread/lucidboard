defmodule Lucidboard.TwiddlerTest do
  use LucidboardWeb.BoardCase
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler
  import Focus

  test "update_board", %{board: board} do
    action = {:update_board, title: "CHANGED IT"}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has updated the board settings." == event.desc
    assert "CHANGED IT" == new_board.title

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  test "update_column", %{board: board} do
    col_lens = Lens.make_lens(:columns) ~> Lens.idx(1)
    actual_col_id = Focus.view(col_lens, board).id

    action = {:update_column, id: actual_col_id, title: "CHANGED IT"}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has updated the `CHANGED IT` column." == event.desc
    assert "CHANGED IT" == Focus.view(col_lens, new_board).title

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  test "update card", %{board: board} do
    card_lens =
      Lens.make_lens(:columns)
      ~> Lens.idx(2)
      ~> Lens.make_lens(:piles)
      ~> Lens.idx(0)
      ~> Lens.make_lens(:cards)
      ~> Lens.idx(0)

    actual_card_id = Focus.view(card_lens, board).id

    {:ok, new_board, tx_fn, event} =
      Twiddler.act(board, {:update_card, id: actual_card_id, body: "OH YEAH"})

    assert "has changed card text." == event.desc
    assert "OH YEAH" == Focus.view(card_lens, new_board).body

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  test "move third column to the first position", %{board: board} do
    # Baseline
    ~w(Col1 Col2 Col3) = titles(board.columns)

    action = {:move_column, id: Enum.at(board.columns, 2).id, new_pos: 0}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has moved the `Col3` column." == event.desc
    assert ~w(Col3 Col1 Col2) == titles(new_board.columns)

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  test "move first column to the last position", %{board: board} do
    action = {:move_column, id: Enum.at(board.columns, 0).id, new_pos: 2}
    {:ok, new_board, tx_fn, _event} = Twiddler.act(board, action)

    assert ~w(Col2 Col3 Col1) == titles(new_board.columns)

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  test "of 4, move the last pile to be first", %{board: board} do
    col_lens = Lens.make_lens(:columns) ~> Lens.idx(2)
    pile_lens = col_lens ~> Lens.make_lens(:piles) ~> Lens.idx(3)

    col = Focus.view(col_lens, board)
    pile = Focus.view(pile_lens, board)

    assert ~w(whoa definitely cheese flapjacks) ==
             col.piles |> first_card_body_of_each_pile()

    action = {:move_pile, id: pile.id, col_id: col.id, new_pos: 0}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has moved a pile." == event.desc

    assert ~w(flapjacks whoa definitely cheese) ==
             col_lens
             |> Focus.view(new_board)
             |> Map.fetch!(:piles)
             |> first_card_body_of_each_pile()

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  # Execute the given transaction function and assert that the given board
  # state matches what was persisted to the database.
  defp execute_tx_and_assert_board_matches(tx_fn, live_board) do
    if tx_fn, do: {:ok, _} = Repo.transaction(tx_fn)
    %{} = db_board = Twiddler.by_id(live_board.id)
    assert db_board == live_board
  end

  # Given a list of columns, return a list of their titles
  defp titles(columns) do
    Enum.map(columns, & &1.title)
  end

  defp first_card_body_of_each_pile(piles) do
    Enum.map(piles, fn p -> hd(p.cards).body end)
  end
end
