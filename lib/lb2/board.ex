defmodule Lb2.Board do
  @moduledoc "Board Context"

  import Ecto.Query
  alias Lb2.Board.{Board, Column, Card}
  alias Lb2.Repo

  def create_test_board do
    create_board(~w(First Second Third))
  end

  def create_card(column_id, content) do
    with %Column{} = col <- column_by_id(column_id),
         {:ok, card} <- do_create_card(content) do
      append_card_to_column(col, card)
    else
      nil -> {:error, "Column not found"}
    end
  end

  def append_card_to_column(%Column{} = col, %Card{} = card) do
    cards = col.cards ++ [card.id]

    with %{valid?: true} = changeset <-
           Column.changeset(col, %{cards: cards}) do
      Repo.update(changeset)
    end
  end

  defp column_by_id(column_id) do
    c in Column, select: c, where: c.id == ^column_id
    |> from()
    |> Repo.one()
  end

  defp do_create_card(content) do
    %Card{}
    |> Card.changeset(%{content: content})
    |> Repo.insert()
  end

  defp create_board(column_names) do
    column_ids = Enum.map(column_names, &create_column/1)

    data = %{name: "Test board", columns: column_ids}

    changeset = Board.changeset(%Board{}, data)

    Repo.insert(changeset)
  end

  defp create_column(name) do
    {:ok, column} =
      %Column{}
      |> Column.changeset(%{name: name})
      |> Repo.insert()

    column.id
  end
end
