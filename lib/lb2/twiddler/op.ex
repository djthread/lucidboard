defmodule Lb2.Twiddler.Op do
  @moduledoc """
  Helper functions for manipulating board data
  """
  alias Ecto.Changeset

  @type ok_or_error :: {:ok, Changeset.t()} | {:error, String.t()}

  @doc """
  Moves an item by its id to a new position in a list

    iex> Op.move_items([%{id: 1}, %{id: 2}], 2, 0)
    {%{id: 2}, [%{id: 2}, %{id: 1}]}
  """
  @spec move_items(list, integer | binary, integer) :: {any, [any]} | :error
  def move_items(items, id, new_pos)
      when is_list(items) and is_integer(new_pos) and length(items) > new_pos do
    items
    |> Enum.with_index()
    |> Enum.find(&(elem(&1, 0).id == id))
    |> case do
      {_item, idx} ->
        {item, leftover} = List.pop_at(items, idx)
        new_list = List.insert_at(leftover, new_pos, item)

        {item, new_list}

      nil ->
        :error
    end
  end
end
