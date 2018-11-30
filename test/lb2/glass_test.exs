defmodule Lb2.GlassTest do
  use Lb2Web.ConnCase, async: true
  import Lb2.BoardFixtures
  alias Lb2.Board.Board
  alias Lb2.Board.{Board, Card, Column, Pile}
  alias Lb2.Glass

  test "get column lens by id" do
    {:ok, lens} = Glass.column_by_id(fixture(), 2)
    assert "Col2" == Focus.view(lens, fixture()).title
    assert :error == Glass.column_by_id(fixture(), 99)
  end

  test "get card lens by id" do
    {:ok, lens} = Glass.card_by_id(fixture(), 2)
    assert "whoa" == Focus.view(lens, fixture()).body
    assert :error == Glass.card_by_id(fixture(), 99)
  end

  test "get pile lens by id" do
    {:ok, lens} = Glass.pile_by_id(fixture(), 2)
    assert 1 == length Focus.view(lens, fixture()).cards
    assert :error == Glass.card_by_id(fixture(), 99)
  end

  # test "set_column_title" do
  #   board = fixture()
  #   cs = Board.changeset(board, %{})

  #   action = %Action{
  #     name: :set_column_title,
  #     args: [
  #       id: "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
  #       title: "CHANGED IT"
  #     ]
  #   }

  #   {:ok, new_cs, event} = B.act(board, cs, action)

  #   assert "has changed a column title to CHANGED IT" == event.desc

  #   assert "CHANGED IT" ==
  #            new_cs
  #            |> Changeset.apply_changes()
  #            |> Map.get(:columns)
  #            |> Enum.at(1)
  #            |> Map.get(:title)
  # end

  # test "reorder_columns" do
  #   board = fixture()
  #   cs = Board.changeset(board, %{})

  #   column_ids = [
  #     "36aa312a-2eb9-4ef8-aebd-0272ae56ca23",
  #     "6a5c5890-61be-4a9e-8520-24b22c4824d8",
  #     "19485672-4cf5-4b6c-af68-42e97c0087d0"
  #   ]

  #   action = %Action{
  #     name: :reorder_columns,
  #     args: [column_ids: column_ids]
  #   }

  #   {:ok, new_cs, event} = B.act(board, cs, action)

  #   assert "has rearranged the columns" == event.desc

  #   assert column_ids ==
  #            new_cs
  #            |> Changeset.apply_changes()
  #            |> Map.get(:columns)
  #            |> Enum.map(fn c -> c.id end)
  # end
end
