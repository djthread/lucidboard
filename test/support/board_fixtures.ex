defmodule Lb2.BoardFixtures do
  @moduledoc "Some board data for unit tests"

  alias Lb2.Board.{Board, Card, Column, Pile}

  def fixture do
    %Board{
      columns: [
        %Column{
          board_id: 1,
          id: 2,
          piles: [
            %Pile{
              cards: [%Card{body: "hi", id: 1, pile_id: 1, pos: 0}],
              column_id: 2,
              id: 1,
              pos: 0
            }
          ],
          pos: 1,
          title: "Col2"
        },
        %Column{
          board_id: 1,
          id: 3,
          piles: [
            %Pile{
              cards: [%Card{body: "definitely", id: 4, pile_id: 3, pos: 0}],
              column_id: 3,
              id: 3,
              pos: 1
            },
            %Pile{
              cards: [
                %Card{body: "whoa", id: 2, pile_id: 2, pos: 0},
                %Card{body: "srs?", id: 3, pile_id: 2, pos: 1}
              ],
              column_id: 3,
              id: 2,
              pos: 0
            }
          ],
          pos: 2,
          title: "Col3"
        },
        %Column{board_id: 1, id: 1, piles: [], pos: 0, title: "Col1"}
      ],
      id: 1,
      inserted_at: ~N[2018-11-27 03:49:28],
      title: "My Test Board",
      updated_at: ~N[2018-11-27 03:49:28]
    }
  end
end