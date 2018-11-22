alias Lb2.Repo
alias Lb2.Board.{Board, Card, Column, Slot}

Repo.insert!(%Board{
  title: "My Test Board",
  columns: [
    %Column{title: "Col1"},
    %Column{title: "Col2", slots: [%Slot{cards: [%Card{body: "hi"}]}]},
    %Column{
      title: "Col3",
      slots: [
        %Slot{
          cards: [
            %Card{body: "hey"},
            %Card{body: "sup"}
          ]
        },
        %Slot{cards: [%Card{body: "definitely"}]}
      ]
    }
  ]
})
