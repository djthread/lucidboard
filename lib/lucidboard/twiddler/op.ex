defmodule Lucidboard.Twiddler.Op do
  @moduledoc """
  Helper functions for manipulating `%Board{}` data
  """

  @doc """
  Moves an item by its id to a new position in a list, updating `pos`
  ordering as needed.

    iex> Op.move_item([%{id: 1, pos: 0}, %{id: 2, pos: 1}], 1, 0)
    {:ok, %{id: 2, pos: 0}, [%{id: 2, pos: 0}, %{id: 1, pos: 1}]}
  """
  @spec move_item([struct], integer, integer) ::
          {:ok, any, [any]} | {:error, String.t()}
  def move_item(items, pos, new_pos)
      when is_list(items) and is_integer(pos) and is_integer(new_pos) and
             pos >= 0 and new_pos >= 0 and length(items) > pos and
             length(items) > new_pos do
    {item, leftover} = List.pop_at(items, pos)
    new_item = Map.put(item, :pos, new_pos)

    new_list =
      leftover
      |> List.insert_at(new_pos, item)
      |> Enum.with_index()
      |> Enum.map(fn {i, pos} -> Map.put(i, :pos, pos) end)

    {:ok, new_item, new_list}
  end

  def move_item(items, pos, new_pos) do
    {:error,
     """
     Error moving pos #{inspect(pos)} to #{inspect(new_pos)} in a \
     #{length(items)}-item list
     """}
  end

  @spec find_pos_by_id([struct], integer) ::
          {:ok, integer} | {:error, String.t()}
  def find_pos_by_id(items, id) do
    case Enum.find_index(items, &(&1.id == id)) do
      nil -> {:error, "Couldn't find id #{id} in #{inspect(items)}"}
      idx -> {:ok, idx}
    end
  end
end
