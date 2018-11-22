defmodule Lb2.LiveBoard do
  @moduledoc """
  Facade module for boards running as processes
  """
  # alias Lb2.Board.{Board, Card, Column}
  alias Lb2.LiveBoard.Instance

  @registry Lb2.BoardRegistry
  @supervisor Lb2.BoardSupervisor

  @spec open(integer) :: DynamicSupervisor.on_start_child()
  def open(id, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    DynamicSupervisor.start_child(supervisor, {Instance, id})
  end

  @spec close(integer) :: :ok | {:error, :not_found}
  def close(id, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, @supervisor)
    [{pid, nil}] = Registry.lookup(@registry, id)
    DynamicSupervisor.terminate_child(supervisor, pid)
  end

  def call(board_id, msg) do
    GenServer.call({:via, Registry, {@registry, board_id}}, msg)
  end

  # def create_card(column_id, content) do
  #   with %Column{} = col <- column_by_id(column_id),
  #        {:ok, card} <- do_create_card(content) do
  #     append_card_to_column(col, card)
  #   else
  #     nil -> {:error, "Column not found"}
  #   end
  # end

  # def append_card_to_column(%Column{} = col, %Card{} = card) do
  #   cards = col.cards ++ [card.id]

  #   with %{valid?: true} = changeset <- Column.changeset(col, %{cards: cards}) do
  #     Repo.update(changeset)
  #   end
  # end

  # defp column_by_id(column_id) do
  #   Repo.one(from(c in Column, where: c.id == ^column_id, select: c))
  # end

  # defp do_create_card(content) do
  #   %Card{}
  #   |> Card.changeset(%{content: content})
  #   |> Repo.insert()
  # end

  # defp create_board(column_names) do
  #   column_ids = Enum.map(column_names, &create_column/1)

  #   data = %{name: "Test board", columns: column_ids}

  #   changeset = Board.changeset(%Board{}, data)

  #   Repo.insert(changeset)
  # end

  # defp create_column(name) do
  #   {:ok, column} =
  #     %Column{}
  #     |> Column.changeset(%{name: name})
  #     |> Repo.insert()

  #   column.id
  # end
end
