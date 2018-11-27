defmodule Lb2.Board.Util do
  @moduledoc """
  Helper functions for maniputaling board data
  """
  alias Ecto.Changeset
  alias Lb2.{BoardScope, ColumnScope, PileScope}
  import Focus

  @type ok_or_error :: {:ok, Changeset.t()} | {:error, String.t()}

  @doc "Update the column of the given id"
  def update_column(changeset, id, fun) do
    board = changeset.apply_changes()

    lens =
      BoardScope.columns_lens()
      ~> Lens.idx(Enum.find_index(board.columns, &(&1.id == id)))

    Focus.set(lens, board, "val")
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
