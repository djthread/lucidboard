defmodule LucidboardWeb.BoardView do
  use LucidboardWeb, :view
  alias Lucidboard.Presence
  alias LucidboardWeb.BoardLive
  alias Phoenix.Socket

  def user_id(:unset), do: 1
  def user_id(assigns), do: assigns.user.id
  def board_id(:unset), do: 1
  def board_id(assigns), do: assigns.board.id

  @doc """
  Get the user's session's locked card id and a list of all locked card ids
  """
  @spec locked_cards(integer, integer, Socket.t() | nil) ::
          {integer | nil, [integer]}
  def locked_cards(user_id, board_id, socket \\ nil)

  def locked_cards(_user_id, board_id, %{assigns: :unset}) do
    list = board_id |> BoardLive.topic() |> Presence.list()
    {nil, locked_card_ids(list)}
  end

  def locked_cards(user_id, board_id, socket) do
    list = board_id |> BoardLive.topic() |> Presence.list()

    user_locked_card_id =
      list
      |> Map.get(user_id)
      |> Map.get(:metas)
      |> Enum.find(fn x -> x.phx_ref == "phx-#{socket.id}" end)
      |> Map.get(:locked_card_id)

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
