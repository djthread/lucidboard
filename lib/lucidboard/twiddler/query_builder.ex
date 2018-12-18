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
  def move_item(queryable, id, old_pos, new_pos, base_fn \\ nil) do
    fun =
      if old_pos < new_pos do
        fn ->
          from(i in queryable, where: i.pos > ^old_pos and i.pos <= ^new_pos)
          |> Repo.update_all(inc: [pos: -1])

          from(i in queryable, where: i.id == ^id)
          |> Repo.update_all(set: [pos: new_pos])
        end
      else
        fn ->
          from(i in queryable, where: i.pos < ^old_pos and i.pos >= ^new_pos)
          |> Repo.update_all(inc: [pos: 1])

          from(i in queryable, where: i.id == ^id)
          |> Repo.update_all(set: [pos: new_pos])
        end
      end

    fn ->
      if is_function(base_fn), do: base_fn.()
      fun.()
    end
  end
end
