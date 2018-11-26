defmodule Lb2.BoardTest do
  use Lb2Web.ConnCase, async: true
  alias Ecto.Changeset
  alias Lb2.Board, as: B
  alias Lb2.Board.Board
  alias Lb2.Board.{Action, Board, Card, Column, Pile}

  test "set_column_title" do
    board = fixture()
    cs = Board.changeset(board, %{})

    action = %Action{
      name: :set_column_title,
      args: [
        id: "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
        title: "CHANGED IT"
      ]
    }

    {:ok, new_cs, event} = B.act(board, cs, action)

    assert "has changed a column title to CHANGED IT" == event.desc

    assert "CHANGED IT" ==
             new_cs
             |> Changeset.apply_changes()
             |> Map.get(:columns)
             |> Enum.at(1)
             |> Map.get(:title)
  end

  test "reorder_columns" do
    board = fixture()
    cs = Board.changeset(board, %{})

    column_ids = [
      "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
      "6a5c5890-61be-4a9e-8520-24b22c4824d8",
      "19485672-4cf5-4b6c-af68-42e97c0087d0"
    ]

    action = %Action{
      name: :reorder_columns,
      args: [column_ids: column_ids]
    }

    {:ok, new_cs, event} = B.act(board, cs, action)

    assert "has rearranged the columns" == event.desc

    assert column_ids ==
             new_cs
             |> Changeset.apply_changes()
             |> Map.get(:columns)
             |> Enum.map(fn c -> c.id end)
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
