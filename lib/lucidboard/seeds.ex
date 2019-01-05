defmodule Lucidboard.Seeds do
  @moduledoc "Some database seed data"
  alias Lucidboard.{Board, Card, Column, Pile, Repo, User}

  def insert! do
    user = Repo.insert!(User.new(name: "bob"))

    Repo.insert!(board(user))
    Repo.insert!(board2(user))
  end

  def board(user \\ nil) do
    user = user || User.new(name: "bob")

    Board.new(
      title: "My Test Board",
      user: user,
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

  def board2(user \\ nil) do
    user = user || User.new(name: "bob")

    Board.new(
      title: "Another Example Board About Nothing",
      user: user,
      columns: [
        Column.new(
          title: "What Went Well",
          pos: 0,
          piles: [
            Pile.new(
              pos: 0,
              cards: [Card.new(pos: 0, body: "Diversionary tactics")]
            ),
            Pile.new(
              pos: 1,
              cards: [Card.new(pos: 1, body: "Bitcoin")]
            ),
            Pile.new(
              pos: 2,
              cards: [
                Card.new(
                  pos: 1,
                  body: """
                  This board is just an example, so we need to cover a range of
                  different cases like maybe having a card with lots and lots of
                  text.
                  """
                )
              ]
            )
          ]
        ),
        Column.new(
          title: "What Didn't Go Well",
          pos: 1,
          piles: [
            Pile.new(
              pos: 0,
              cards: [Card.new(pos: 0, body: "The wall")]
            ),
            Pile.new(
              pos: 0,
              cards: [Card.new(pos: 0, body: "that whole free market thing")]
            ),
          ]
        ),
        Column.new(
          title: "What Was Amazing",
          pos: 2,
          piles: [
            Pile.new(
              pos: 0,
              cards: [
                Card.new(pos: 0, body: "political entertainment"),
                Card.new(pos: 1, body: "like seriously"),
                Card.new(pos: 2, body: "like you've got to be kidding")
              ]
            ),
            Pile.new(
              pos: 1,
              cards: [
                Card.new(pos: 0, body: "Supercalifragilisticexpialidocious")
              ]
            ),
            Pile.new(pos: 2, cards: [Card.new(pos: 0, body: "orange juice")]),
            Pile.new(pos: 3, cards: [Card.new(pos: 0, body: "bandanas")]),
            Pile.new(pos: 4, cards: [Card.new(pos: 0, body: "lucidboard?")])
          ]
        )
      ]
    )
  end
end
