alias Lucidboard.Repo
alias Lucidboard.Board.{Board, Card, Column, Pile}

Repo.insert! %Board{
  title: "My Test Board",
  columns: [
    %Column{title: "Col1", pos: 0},
    %Column{
      title: "Col2",
      pos: 1,
      piles: [
        %Pile{pos: 0, cards: [%Card{pos: 0, body: "hi"}]}
      ]
    },
    %Column{
      title: "Col3",
      pos: 2,
      piles: [
        %Pile{
          pos: 0,
          cards: [
            %Card{pos: 0, body: "hey"},
            %Card{pos: 1, body: "sup"}
          ]
        },
        %Pile{pos: 1, cards: [%Card{pos: 0, body: "definitely"}]}
      ]
    }
  ]
}
