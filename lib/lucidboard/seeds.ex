defmodule Lucidboard.Seeds do
  @moduledoc "Some database seed data"
  alias Lucidboard.{Board, Card, Column, Pile, User}

  def user do
  end

  def board do
    Board.new(
      title: "My Test Board",
      user: User.new(name: "bob"),
      columns: [
        Column.new(title: "Col1", pos: 0),
        Column.new(
          title: "Col2",
          pos: 1,
          piles: [
            Pile.new(pos: 0, cards: [Card.new(pos: 0, body: "hi")])
          ]
        ),
        Column.new(
          title: "Col3",
          pos: 2,
          piles: [
            Pile.new(
              pos: 0,
              cards: [
                Card.new(pos: 0, body: "whoa"),
                Card.new(pos: 1, body: "srs?"),
                Card.new(pos: 2, body: "neat")
              ]
            ),
            Pile.new(pos: 1, cards: [Card.new(pos: 0, body: "definitely")]),
            Pile.new(pos: 2, cards: [Card.new(pos: 0, body: "cheese")]),
            Pile.new(pos: 3, cards: [Card.new(pos: 0, body: "flapjacks")])
          ]
        )
      ]
    )
  end
end
