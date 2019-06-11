defmodule Lucidboard.Twiddler.Op do
  @moduledoc """
  Helper functions for manipulating `%Board{}` data.

  Some functions return both "built" and "loaded"-tagged structs. The built
  structs are intended to be saved to the db while the loaded ones are
  intended to be injected into the running board state.
  """
  import Ecto.Query
  alias Ecto.UUID
  alias Lucidboard.{Board, Card, Column, Like, Pile, Repo, User}
  alias Lucidboard.LiveBoard.Scribe
  alias Lucidboard.Twiddler.Glass

  @spec column_by_id(Board.t(), integer) :: {:ok, Column.t()} | :not_found
  def column_by_id(board, id) do
    with {:ok, lens} <- Glass.column_by_id(board, id) do
      {:ok, Focus.view(board, lens)}
    end
  end

  @spec card_by_id(Board.t(), integer) :: {:ok, Card.t()} | :not_found
  def card_by_id(board, id) do
    with {:ok, path} <- Glass.card_path_by_id(board, id) do
      {:ok, Glass.card_by_path(board, path)}
    end
  end

  def remove_item(items, pos) do
    {_item, leftover} = List.pop_at(items, pos)
    renumber_positions(leftover)
  end

  @doc """
  Moves an item by its id to a new position in a list, updating `pos`
  ordering as needed.

    iex> Op.move_item([%{id: 1, pos: 0}, %{id: 2, pos: 1}], 1, 0)
    {:ok, %{id: 2, pos: 0}, [%{id: 2, pos: 0}, %{id: 1, pos: 1}]}
  """
  @spec move_item([struct], integer, integer) ::
          {:ok, struct, [struct]} | {:error, String.t()}
  def move_item(items, pos, new_pos)
      when is_list(items) and is_integer(pos) and is_integer(new_pos) and
             pos >= 0 and new_pos >= 0 and
             length(items) > pos and
             length(items) > new_pos do
    {item, leftover} = List.pop_at(items, pos)
    new_list = leftover |> List.insert_at(new_pos, item) |> renumber_positions()

    {:ok, Enum.at(new_list, new_pos), new_list}
  end

  def move_item(items, pos, new_pos) do
    {:error,
     """
     Error moving pos #{inspect(pos)} to #{inspect(new_pos)} in a \
     #{length(items)}-item list\
     """}
  end

  @doc """
  Lifts a pile from a column, reflowing the `pos` fields of surrounding
  piles.

  Note that while the pile will be removed from the returned board structure,
  it still exists in the database with an overlapping `pos`! The caller's
  next step should be to insert the pile back into the board, update the
  `pos` and `column_id` fields, and update the db.
  """
  @spec cut_pile(Board.t(), Glass.path()) ::
          {:ok, Board.t(), Pile.t(), Scribe.tx_fn()}
  def cut_pile(board, pile_path) do
    col = Glass.column_by_path(board, pile_path)
    pile = Glass.pile_by_path(board, pile_path)

    {:ok, pile_pos} = find_pos_by_id(col.piles, pile.id)
    new_col = %{col | piles: remove_item(col.piles, pile_pos)}

    {:ok, col_pos} = find_pos_by_id(board.columns, col.id)
    new_columns = List.replace_at(board.columns, col_pos, new_col)
    new_board = Map.put(board, :columns, new_columns)

    reflow_tx_fn = fn ->
      q = from(p in Pile, where: p.column_id == ^col.id and p.pos > ^pile_pos)
      Repo.update_all(q, inc: [pos: -1])
    end

    {:ok, new_board, pile, reflow_tx_fn}
  end

  @doc """
  Remove a card from the board, renumbering surrounding elements' positions.
  Any orphaned Pile is deleted.

  Note that the tx_fn does not delete the card record. This allows the card
  to be moved to another location before our tx_fn is executed (which could
  delete the card if it was the only one in the pile when the pile goes).
  """
  @spec cut_card(Board.t(), Glass.path()) ::
          {:ok, Board.t(), Card.t(), Scribe.tx_fn()}
  def cut_card(board, card_path) do
    pile_lens = Glass.pile_lens_by_path(card_path)

    col = Focus.view(board, Glass.column_lens_by_path(card_path))
    pile = Focus.view(board, pile_lens)
    card = Focus.view(board, Glass.card_lens_by_path(card_path))

    {:ok, card_pos} = find_pos_by_id(pile.cards, card.id)
    new_pile = %{pile | cards: remove_item(pile.cards, card_pos)}

    if Enum.empty?(new_pile.cards) do
      {:ok, pile_pos} = find_pos_by_id(col.piles, pile.id)
      new_col = %{col | piles: remove_item(col.piles, pile_pos)}

      {:ok, col_pos} = find_pos_by_id(board.columns, col.id)
      new_columns = List.replace_at(board.columns, col_pos, new_col)
      new_board = Map.put(board, :columns, new_columns)
      q = from(p in Pile, where: p.pos > ^pile_pos and p.column_id == ^col.id)

      tx_fn = fn ->
        Repo.update_all(q, inc: [pos: -1])
        repo_delete_pile(new_pile)
      end

      {:ok, new_board, card, tx_fn}
    else
      new_board = Focus.set(board, pile_lens, new_pile)
      q = from(c in Card, where: c.pile_id == ^pile.id and c.pos > ^card_pos)
      tx_fn = fn -> Repo.update_all(q, inc: [pos: -1]) end

      {:ok, new_board, card, tx_fn}
    end
  end

  @doc "Add a card (already existing in the db) to the top of a pile"
  @spec add_card_to_pile(Board.t(), Card.t(), Lens.t()) ::
          {:ok, Board.t(), Scribe.tx_fn()}
  def add_card_to_pile(board, card, pile_lens) do
    pile = Focus.view(pile_lens, board)
    new_card = Map.put(card, :pile_id, pile.id)
    new_cards = renumber_positions([new_card | pile.cards])
    new_pile = Map.put(pile, :cards, new_cards)
    new_board = Focus.set(pile_lens, board, new_pile)

    tx_fn = fn ->
      q = from(c in Card, where: c.pile_id == ^pile.id)
      Repo.update_all(q, inc: [pos: 1])
      q = from(c in Card, where: c.id == ^card.id)
      Repo.update_all(q, set: [pile_id: pile.id, pos: 0])
    end

    {:ok, new_board, tx_fn}
  end

  @doc """
  Add a card (already existing in the db) to a column by creating the
  intermediate pile
  """
  @spec add_card_to_column(Board.t(), Card.t(), Lens.t(), integer) ::
          {:ok, Board.t(), Scribe.tx_fn()}
  def add_card_to_column(board, card, col_lens, pos) do
    pile_uuid = UUID.generate()
    col_id = Focus.view(col_lens, board).id
    new_card = %{card | pile_id: pile_uuid, pos: 0}

    new_pile =
      Pile.new(id: pile_uuid, column_id: col_id, pos: pos, cards: [new_card])

    insert_pile_fn = fn ->
      Repo.insert!(new_pile)

      card
      |> Card.changeset(%{pile_id: new_pile.id})
      |> Repo.update!()
    end

    {:ok, new_board, add_pile_fn} =
      add_pile_to_column(board, mark_loaded(new_pile), col_lens, pos)

    {:ok, new_board, [insert_pile_fn, add_pile_fn]}
  end

  @doc "Add a pile (already existing in the db) to a column"
  @spec add_pile_to_column(Board.t(), Pile.t(), Lens.t(), integer) ::
          {:ok, Board.t(), Scribe.tx_fn()}
  def add_pile_to_column(board, pile, col_lens, pos) do
    col = Focus.view(col_lens, board)
    new_pile = Map.put(pile, :column_id, col.id)
    new_piles = renumber_positions(List.insert_at(col.piles, pos, new_pile))
    new_col = Map.put(col, :piles, new_piles)

    new_board = Focus.set(col_lens, board, new_col)

    tx_fn = fn ->
      q = from(p in Pile, where: p.column_id == ^col.id and p.pos >= ^pos)
      Repo.update_all(q, inc: [pos: 1])
      q = from(p in Pile, where: p.id == ^pile.id)
      Repo.update_all(q, set: [column_id: col.id, pos: pos])
    end

    {:ok, new_board, tx_fn}
  end

  @spec find_pos_by_id([struct], integer) ::
          {:ok, integer} | {:error, String.t()}
  def find_pos_by_id(items, id) do
    case Enum.find_index(items, &(&1.id == id)) do
      nil -> {:error, "Couldn't find id #{id} in #{inspect(items)}"}
      idx -> {:ok, idx}
    end
  end

  @doc "Add a new pile at the end of the column with one locked card."
  @spec add_locked_card(Column.t(), integer) ::
          {:ok, Column.t(), Column.t(), Twiddler.meta()}
  def add_locked_card(%Column{piles: piles} = column, user_id) do
    pile_uuid = UUID.generate()
    new_card = Card.new(pile_id: pile_uuid, user_id: user_id, locked: true)

    new_pile =
      Pile.new(
        id: pile_uuid,
        column_id: column.id,
        pos: if(piles == [], do: 0, else: List.last(piles).pos + 1),
        cards: [new_card]
      )

    built_col = %{column | piles: List.insert_at(piles, -1, new_pile)}

    loaded_pile = %{new_pile | cards: [mark_loaded(new_card)]}
    loaded_piles = List.insert_at(piles, -1, mark_loaded(loaded_pile))
    loaded_col = %{column | piles: loaded_piles}

    {:ok, built_col, loaded_col, %{card: new_card}}
  end

  @doc """
  Given a list of reordered piles, renumber the `:pos` fields and build a
  tx_fn to sync the database
  """
  def renumber_piles(piles) do
    renumbered = renumber_positions(piles)

    tx_fn = fn ->
      Enum.each(renumbered, fn pile ->
        q = from(p in Pile, where: p.id == ^pile.id)
        Repo.update_all(q, set: [pos: pile.pos])
      end)
    end

    {renumbered, tx_fn}
  end

  @doc "Move the top card to the bottom of a pile"
  def flip_pile(board, pile_lens) do
    %{cards: [top_card | cards]} = pile = Focus.view(board, pile_lens)
    new_cards = cards |> List.insert_at(-1, top_card) |> renumber_positions()
    new_pile = %{pile | cards: new_cards}

    cs =
      Card.changeset(top_card, %{pos: new_cards |> List.last() |> Map.get(:pos)})

    tx_fn = fn ->
      q = from(c in Card, where: c.pile_id == ^pile.id and c.pos > 0)
      Repo.update_all(q, inc: [pos: -1])
      Repo.update(cs)
    end

    {:ok, Focus.set(pile_lens, board, new_pile), tx_fn}
  end

  @doc "Move the last card to the top of a pile"
  def unflip_pile(board, pile_lens) do
    pile = Focus.view(board, pile_lens)
    {last_card, cards} = List.pop_at(pile.cards, -1)
    new_cards = cards |> List.insert_at(0, last_card) |> renumber_positions()
    new_pile = %{pile | cards: new_cards}

    cs = Card.changeset(last_card, %{pos: 0})

    tx_fn = fn ->
      q =
        from(c in Card, where: c.pile_id == ^pile.id and c.pos < ^last_card.pos)

      Repo.update_all(q, inc: [pos: 1])
      Repo.update(cs)
    end

    {:ok, Focus.set(pile_lens, board, new_pile), tx_fn}
  end

  @doc "Create a like"
  def like(%Card{id: card_id} = card, %User{id: user_id}) do
    built_like = Like.new(card_id: card_id, user_id: user_id)
    new_likes = [mark_loaded(built_like) | card.likes]
    new_card = sort_likes(%{card | likes: new_likes})

    {:ok, built_like, new_card}
  end

  @doc "Remove a like"
  def unlike(%Card{likes: likes} = card, %User{id: user_id}) do
    case Enum.find_index(likes, fn l -> l.user_id == user_id end) do
      nil ->
        {:error, :not_found}

      idx ->
        like_to_delete = Enum.at(likes, idx)
        new_card = %{card | likes: List.delete_at(likes, idx)}
        {:ok, like_to_delete, new_card}
    end
  end

  @doc "Our arbitrary logic for sorting likes on a card"
  def sort_likes(%Card{likes: likes} = card) do
    new_likes = Enum.sort(likes, &(&1.id < &2.id))
    %{card | likes: new_likes}
  end

  @doc """
  Recalculate the target position for a pile in a column

  This is important because if a pile is moved lower in the same column, the
  fact that the pile is being removed (and lower piles renumbered) has an
  affect on the actual position we want to then splice it into.

  Note that this is only important if a pile is being dragged. If a card from
  a pile is moved, the pile will still remain, and this logic does not apply.

  The original board (that the user's command is based on) should be passed
  in here since that is what `target_pos` is based on.
  """
  def calculate_pile_pos(board, card_or_pile_path, target_col_id, target_pos) do
    moving_a_pile? = Glass.pile_path?(card_or_pile_path)
    pile = Glass.pile_by_path(board, card_or_pile_path)

    if target_col_id == Glass.column_by_path(board, card_or_pile_path).id and
         pile.pos < target_pos and
         (moving_a_pile? or length(pile.cards) == 1) do
      target_pos - 1
    else
      target_pos
    end
  end

  @doc "Calculate the number of likes"
  @spec likes(Pile.t()) :: integer
  def likes(%Pile{cards: cards}) do
    Enum.reduce(cards, 0, fn %{likes: likes}, acc ->
      acc + length(likes)
    end)
  end

  defp renumber_positions(items) do
    items
    |> Enum.with_index()
    |> Enum.map(fn {i, pos} -> Map.put(i, :pos, pos) end)
  end

  # This seems necessary because `on_delete: :delete_all` does not cascade to
  # children. So, if a pile is deleted, we need to first delete all its cards
  # because those cards may, in turn, contain likes.
  defp repo_delete_pile(pile) do
    Enum.each(pile.cards, fn card ->
      Repo.delete(card)
    end)

    Repo.delete(pile)
  end

  # This is important to mark the metadata on our schema structs so they seem
  # to have been already saved and loaded from the database. Without it, our
  # in-memory board state will not align to the same data if it was fetched
  # from the database. We rely on unit tests to ensure our in-memory board is
  # actually the same as the db state (after the transaction function is
  # executed).
  defp mark_loaded(item) do
    Ecto.put_meta(item, state: :loaded)
  end
end
