alias Lb2.Repo
alias Lb2.Board.{Board, Card, Column, Pile}

%Board{
  title: "My Test Board",
  columns: [
    %Column{title: "Col1"},
    %Column{
      title: "Col2",
      piles: [
        Pile.create(cards: [Card.create(body: "hi")])
      ]
    },
    %Column{
      title: "Col3",
      piles: [
        Pile.create(
          cards: [
            Card.create(body: "hey"),
            Card.create(body: "sup")
          ]
        ),
        Pile.create(cards: [Card.create(body: "definitely")])
      ]
    }
  ]
}
|> Repo.insert!()
