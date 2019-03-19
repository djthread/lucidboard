defmodule Lucidboard.Twiddler.Op do
  @moduledoc """
  Helper functions for manipulating `%Board{}` data.

  Some functions return both "built" and "loaded"-tagged structs. The built
  structs are intended to be saved to the db while the loaded ones are
  intended to be injected into the running board state.
  """

  @doc """
  Moves an item by its id to a new position in a list, updating `pos`
  ordering as needed.

    iex> Op.move_item([%{id: 1, pos: 0}, %{id: 2, pos: 1}], 1, 0)
    {:ok, %{id: 2, pos: 0}, [%{id: 2, pos: 0}, %{id: 1, pos: 1}]}
  """
  alias Ecto.UUID
  alias Lucidboard.{Card, Column, Like, Pile, Twiddler, User}

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
     #{length(items)}-item list\
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

  # This is important to mark the metadata on our schema structs so they seem
  # to have been already saved and loaded from the database. Without it, our
  # in-memory board state will no align to the same data if it was fetched from
  # the database. We rely on unit tests to ensure our in-memory board is
  # actually the same as the db state (after the transaction function is
  # executed).
  defp mark_loaded(item) do
    Ecto.put_meta(item, state: :loaded)
  end
end
