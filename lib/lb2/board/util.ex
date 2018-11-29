defmodule Lb2.Board.Util do
  @moduledoc """
  Helper functions for maniputaling board data
  """
  alias Ecto.Changeset
  alias Lb2.Board.Board
  alias Lb2.{BoardScope, ColumnScope, PileScope}
  import Focus

  @type ok_or_error :: {:ok, Changeset.t()} | {:error, String.t()}

  @doc "Update the title of a given column by id"
  def column_set_title(changeset, id, title) do
    board = Changeset.apply_changes(changeset)

    new_board =
      Lens.make_lens(:columns)
      ~> Lens.make_lens(Enum.find_index(board.columns, &(&1.id == id)))
      # BoardScope.columns_lens()
      # ~> Lens.idx(Enum.find_index(board.columns, &(&1.id == id)))
      # ~> ColumnScope.title_lens()
      # |> Focus.set(%{columns: "sap"}, title)
      |> Focus.set(%Board{columns: [%{id: 2}, %{id: 3}]}, title)
      # |> Focus.view(board)
      |> IO.inspect()

    with %{columns: new_columns} <- new_board,
         %{valid?: true} = new_changeset <-
           Board.changeset(changeset, %{columns: new_columns}) do
      {:ok, new_changeset}
    end
  end

  def change_column(columns, id, fun) do
    columns
    |> Enum.reduce([], fn col, acc ->
      col = if id == col.id, do: fun.(col), else: col
      [col | acc]
    end)
    |> Enum.reverse()
  end

  def recursive_struct_to_map(%{__struct__: _} = struct) do
    struct |> Map.from_struct() |> recursive_struct_to_map()
  end

  def recursive_struct_to_map(%{} = map) do
    Enum.reduce(map, %{}, fn {k, v}, acc ->
      Map.put(acc, k, recursive_struct_to_map(v))
    end)
  end

  def recursive_struct_to_map(list) when is_list(list) do
    Enum.map(list, fn i -> recursive_struct_to_map(i) end)
  end

  def recursive_struct_to_map(val), do: val
end
