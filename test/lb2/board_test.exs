defmodule Lb2.BoardTest do
  use Lb2Web.ConnCase, async: true
  alias Ecto.Changeset
  alias Lb2.Board, as: B
  alias Lb2.Board.Board
  alias Lb2.Board.{Board, Card, Column, Event, Pile}

  test "set_column_title" do
    board = fixture()
    cs = Board.changeset(board, %{})

    event = %Event{
      action: :set_column_title,
      args: [
        id: "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
        title: "CHANGED IT"
      ]
    }

    {:ok, new_cs} = B.act(board, cs, event)

    assert "CHANGED IT" ==
             new_cs
             |> Changeset.apply_changes()
             |> Map.get(:columns)
             |> Enum.at(1)
             |> Map.get(:title)
  end

  defp fixture do
    %Board{
      title: "My Test Board",
      columns: [
        %Column{title: "Col1", id: "19485672-4cf5-4b6c-af68-42e97c0087d0"},
        %Column{
          title: "Col2",
          id: "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
          piles: [%Pile{cards: [%Card{body: "hi"}]}]
        },
        %Column{
          title: "Col3",
          id: "6a5c5890-61be-4a9e-8520-24b22c4824d8",
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
  end
end
