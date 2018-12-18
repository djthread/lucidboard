defmodule Lucidboard.Twiddler.OpTest do
  use ExUnit.Case
  import Lucidboard.BoardFixtures
  alias Lucidboard.Twiddler.Op

  doctest Lucidboard.Twiddler.Op

  # Note that this test does not check the tx_fn. TwiddlerTest will cover that.
  test "move_items" do
    bodies = fn cards -> Enum.map(cards, & &1.body) end
    cards = cards_fixture()

    # Baseline
    assert ~w(fred wilma pebbles) == bodies.(cards)

    {t1_card, t1_cards} = Op.move_item(cards, 0, 2)
    assert "fred" == t1_card.body
    assert ~w(wilma pebbles fred) == bodies.(t1_cards)

    # 2 is the max position since length(cards) == 3
    assert_raise(FunctionClauseError, fn ->
      Op.move_item(cards, 1, 3)
    end)

    assert_raise(FunctionClauseError, fn ->
      Op.move_item(cards, 9, 0)
    end)
  end
end
