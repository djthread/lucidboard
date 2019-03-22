defmodule Lucidboard.Twiddler.QueryBuilder do
  @moduledoc """
  Helps build our transaction functions by chaining together Repo calls.

  For convenience, the optional `base_fn` arguments are functions with
  preexisting database calls which should be ran before the new ones being
  added. This function is ultimately intended to be passed to
  `&Repo.transaction/l` for execution.
  """
  import Ecto.Query
  alias Lucidboard.LiveBoard.Scribe
  alias Lucidboard.{Card, Repo}

  @doc """
  Return a function that will remove item with id `id` and position `pos`.
  """
  def remove_item(q, id, pos) do
    queryable = from(i in q, where: i.pos > ^pos)

    fn ->
      Repo.update_all(queryable, inc: [pos: -1])
      Repo.delete(Repo.one!(from(i in q, where: i.id == ^id)))
    end
  end

  def delete_card(card) do
    Repo.delete(Repo.one!(from(c in Card, where: c.id == ^card.id)))
  end

  @doc """
  Return a function that will move item with id `id` and position `pos` to
  `new_pos` in the database.

  Works for Columns, Piles, or Cards. To aid in building the transaction
  function, the first argument must be an `Ecto.Queryable.t()`. (Eg. `from(c
  in Column, where: c.board_id == ^board.id)`)
  """
  @spec move_item(Ecto.Queryable.t(), integer, integer, integer) ::
          Scribe.tx_fn()
  def move_item(q, id, pos, new_pos) do
    {queryable, pos_delta} =
      if pos < new_pos do
        qq = from(i in q, where: i.pos > ^pos and i.pos <= ^new_pos)
        {qq, -1}
      else
        qq = from(i in q, where: i.pos < ^pos and i.pos >= ^new_pos)
        {qq, 1}
      end

    fn ->
      Repo.update_all(queryable, inc: [pos: pos_delta])
      Repo.update_all(from(i in q, where: i.id == ^id), set: [pos: new_pos])
    end
  end
end
