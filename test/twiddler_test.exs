defmodule Lucidboard.TwiddlerTest do
  use LucidboardWeb.BoardCase
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler
  import Focus

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

  test "set_column_title", %{board: board} do
    col_lens = Lens.make_lens(:columns) ~> Lens.idx(1)
    actual_col_id = Focus.view(col_lens, board).id

    action = {:set_column_title, id: actual_col_id, title: "CHANGED IT"}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has changed a column title to CHANGED IT." == event.desc
    assert "CHANGED IT" == Focus.view(col_lens, new_board).title

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  @tag :skip
  test "move_column", %{board: board} do
    titles = fn columns -> Enum.map(columns, & &1.title) end

    # Baseline
    ~w(Col1 Col2 Col3) = titles.(board.columns)

    # Move third column to the first position
    action = {:move_column, id: Enum.at(board.columns, 2).id, new_pos: 0}
    {:ok, new_board, tx_fn, event} = Twiddler.act(board, action)

    assert "has moved the `Col3` column." == event.desc
    assert ~w(Col3 Col1 Col2) == titles.(new_board.columns)

    execute_tx_and_assert_board_matches(tx_fn, new_board)
  end

  # Execute the given transaction function and assert that the given board
  # state matches what was persisted to the database.
  defp execute_tx_and_assert_board_matches(tx_fn, live_board) do
    if tx_fn, do: {:ok, _} = Repo.transaction(tx_fn)
    %{} = db_board = Twiddler.by_id(live_board.id)
    assert db_board == live_board
  end
end
