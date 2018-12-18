defmodule Lucidboard.Twiddler.QueryBuilder do
  @moduledoc """
  Helps build our transaction functions by chaining together Repo calls
  """
  import Ecto.Query
  alias Lucidboard.Repo

  @doc """
  Works for Columns, Piles, or Boards. To aid in building the transaction function, the first argument must be an `Ecto.Queryable.t()`. (Eg. `from(c in Column, where: c.board_id == ^board.id)`)
  """
  @spec move_item(Ecto.Queryable.t(), integer, integer, fun | nil) :: function
  def move_item(queryable, old_pos, new_pos, base_fn \\ nil) do
    fn ->
      if is_function(base_fn), do: base_fn.()

      {n, _} =
        from(i in queryable, where: i.pos >= ^old_pos and i.pos < ^new_pos)
        |> Repo.update_all(inc: [pos: 1])

      IO.puts(".........------ n: #{inspect(n)}")

      {1, _} =
        from(i in queryable, where: i.pos == ^old_pos)
        |> Repo.update_all(set: [pos: new_pos])
    end

    # order song
    # 1     Happy Birthday
    # 2     Beat It
    # 3     Never Gonna Give You Up
    # 4     Safety Dance
    # 5     Imperial March
    # And you want to move Beat It to the end, you would have two queries:

    # update table
    #   set order = order - 1
    #   where order >= 2 and order <= 5;

    # update table
    #   set order = 5
    #   where song = 'Beat It'
  end
end
