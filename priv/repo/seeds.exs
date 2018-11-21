alias Lb2.Repo
alias Lb2.{Board, Card, Column}

Repo.insert!(%Board{
  title: "My Test Board",
  columns: [
    %Column{title: "Col1"},
    %Column{title: "Col2", cards: [%Card{body: "hi"}]},
    %Column{
      title: "Col3",
      cards: [
        %Card{body: "hey"},
        %Card{body: "sup"}
      ]
    }
  ]
})
