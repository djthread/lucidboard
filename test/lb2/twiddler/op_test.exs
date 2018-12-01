defmodule Lb2.Twiddler.OpTest do
  use ExUnit.Case, async: true
  import Lb2.BoardFixtures
  alias Lb2.Twiddler.Op

  doctest Lb2.Twiddler.Op

  test "move_items" do
    bodies = fn cards -> Enum.map(cards, & &1.body) end
    cards = cards_fixture()

    # Baseline
    assert ~w(fred wilma pebbles) == bodies.(cards)

    {t1_card, t1_cards} = Op.move_items(cards, 1, 2)
    assert "fred" == t1_card.body
    assert ~w(wilma pebbles fred) == bodies.(t1_cards)

    # 2 is the max position since length(cards) == 3
    assert_raise(FunctionClauseError, fn ->
      Op.move_items(cards, 1, 3)
    end)

    assert :error == Op.move_items(cards, 9, 0)
  end
end
