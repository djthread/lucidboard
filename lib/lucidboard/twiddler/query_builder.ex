defmodule Lucidboard.Twiddler.QueryBuilder do
  @moduledoc """
  Helps build our transaction functions by chaining together Repo calls.

  For convenience, the optional `base_fn` arguments are functions with
  preexisting database calls which should be ran before the new ones being
  added. This function is ultimately intended to be passed to
  `&Repo.transaction/l` for execution.
  """
  import Ecto.Query
  alias Lucidboard.{Repo}

  @doc """
  Return a function that will move item with id `id` and position `old_pos`
  to `new_pos` in the database.

  Works for Columns, Piles, or Boards. To aid in building the transaction
  function, the first argument must be an `Ecto.Queryable.t()`. (Eg. `from(c
  in Column, where: c.board_id == ^board.id)`)
  """
  @spec move_item(Ecto.Queryable.t(), integer, integer, fun | nil) :: function
  def move_item(q, id, old_pos, new_pos, base_fn \\ nil) do
    {queryable, pos_delta} =
      if old_pos < new_pos do
        qq = from(i in q, where: i.pos > ^old_pos and i.pos <= ^new_pos)
        {qq, -1}
      else
        qq = from(i in q, where: i.pos < ^old_pos and i.pos >= ^new_pos)
        {qq, 1}
      end

    fn ->
      if is_function(base_fn), do: base_fn.()
      Repo.update_all(queryable, inc: [pos: pos_delta])
      Repo.update_all(from(i in q, where: i.id == ^id), set: [pos: new_pos])
    end
  end
end
