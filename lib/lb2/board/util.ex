defmodule Lb2.Board.Util do
  @moduledoc """
  Helper functions for maniputaling board data
  """

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

  # def find_column(board, changeset, event) do

  # end
end
