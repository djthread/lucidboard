defmodule LucidboardWeb.BoardView do
  use LucidboardWeb, :view
  alias Lucidboard.Presence
  alias LucidboardWeb.BoardLive

  def user_id(:unset), do: 1
  def user_id(assigns), do: assigns.user.id
  def board_id(:unset), do: 1
  def board_id(assigns), do: assigns.board.id

  @doc """
  Get the user's session's locked card id and a list of all locked card ids
  """
  @spec locked_cards(integer, integer, String.t() | nil) ::
          {integer | nil, [integer]}
  def locked_cards(user_id, board_id, socket_id \\ nil)

  # def locked_cards(_user_id, board_id, socket_id) do
  #   list = board_id |> BoardLive.topic() |> Presence.list()
  #   {nil, locked_card_ids(list)}
  # end

  def locked_cards(user_id, board_id, socket_id) do
    list = board_id |> BoardLive.topic() |> Presence.list()

    user_locked_card_id =
      case Map.get(list, to_string(user_id)) do
        %{} = map ->
          map
          |> Map.get(:metas)
          |> Enum.find(fn x ->
            x.lv_ref == socket_id
          end)
          |> (fn map_maybe ->
                if is_map(map_maybe),
                  do: Map.get(map_maybe, :locked_card_id),
                  else: nil
              end).()

        _ ->
          nil
      end

    {user_locked_card_id, locked_card_ids(list)}
  end

  def locked_card_ids(presence_list) do
    Enum.reduce(presence_list, [], fn {_user_id, %{metas: metas}}, acc ->
      acc ++
        Enum.reduce(metas, [], fn
          %{locked_card_id: card_id}, acc2 -> acc2 ++ [card_id]
          %{}, acc2 -> acc2
        end)
    end)
  end
end
