alias Lb2.Repo
alias Lb2.Board.{Board, Card, Column, Pile}

%Board{
  title: "My Test Board",
  columns: [
    %Column{title: "Col1"},
    %Column{title: "Col2", piles: [%Pile{cards: [%Card{body: "hi"}]}]},
    %Column{
      title: "Col3",
      piles: [
        %Pile{
          cards: [
            %Card{body: "hey"},
            %Card{body: "sup"}
          ]
        },
        %Pile{cards: [%Card{body: "definitely"}]}
      ]
    }
  ]
}
|> Repo.insert!()
