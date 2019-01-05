defmodule Lucidboard.Seeds do
  @moduledoc "Some database seed data"
  alias Lucidboard.{Board, Card, Column, Pile, User}

  def user do
  end

  def board do
    %Board{
      title: "My Test Board",
      user: User.new(name: "bob"),
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
                %Card{pos: 0, body: "whoa"},
                %Card{pos: 1, body: "srs?"},
                %Card{pos: 2, body: "neat"}
              ]
            },
            %Pile{pos: 1, cards: [%Card{pos: 0, body: "definitely"}]},
            %Pile{pos: 2, cards: [%Card{pos: 0, body: "cheese"}]},
            %Pile{pos: 3, cards: [%Card{pos: 0, body: "flapjacks"}]}
          ]
        }
      ]
    }
  end
end
