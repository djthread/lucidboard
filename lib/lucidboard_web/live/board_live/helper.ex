defmodule LucidboardWeb.BoardLive.Helper do
  @moduledoc "Functionality to help the BoardLive"
  import Phoenix.LiveView, only: [assign: 2, assign: 3]
  alias Ecto.Changeset
  alias Lucidboard.{Account, Card, Column, LiveBoard, Presence}
  alias LucidboardWeb.BoardLive
  alias LucidboardWeb.BoardLive.Search
  alias Phoenix.LiveView.Socket

  @debounce_timeout 1_000

  defmodule RoleSuggest do
    @moduledoc "Holds data related to role autocompletion"
    defstruct q: nil, list: [], timer: nil
  end

  def user(%Socket{assigns: %{user: user}}), do: user

  def user_id(%Socket{assigns: %{user: %{id: id}}}), do: id

  def finish_card_edit(socket) do
    Presence.update(
      self(),
      BoardLive.topic(socket),
      socket.assigns.user.id,
      &Map.drop(&1, [:locked_card_id])
    )

    assigns = Map.drop(socket.assigns, [:card_changeset])
    Map.put(socket, :assigns, assigns)
  end

  def presence_lock_card(socket, card) do
    Presence.update(
      self(),
      BoardLive.topic(socket),
      socket.assigns.user.id,
      &Map.put(&1, :locked_card_id, card.id)
    )

    assign(socket, :card_changeset, Card.changeset(card))
  end

  @spec save_card(Socket.t(), map) :: {:ok | :invalid, Socket.t()}
  def save_card(socket, form_data) do
    card = Changeset.apply_changes(socket.assigns.card_changeset)

    case Card.changeset(card, form_data["card"]) do
      %{valid?: true} = changeset ->
        card = Changeset.apply_changes(changeset)

        unless delete_card_if_empty(socket, card) do
          data =
            if card.settings do
              %{
                id: card.id,
                body: String.trim(card.body),
                settings: %{color: card.settings.color}
              }
            else
              %{id: card.id, body: String.trim(card.body)}
            end

          live_board_action({:update_card, data}, socket)
        end

        {:ok, finish_card_edit(socket)}

      invalid_changeset ->
        {:invalid, assign(socket, card_changeset: invalid_changeset)}
    end
  end

  def delete_card_if_empty(socket, card) do
    if "" == String.trim(card.body || "") do
      live_board_action({:delete_card, %{id: card.id}}, socket)
      true
    else
      false
    end
  end

  def live_board_action(action, %Socket{} = socket) do
    live_board_action(action, socket.assigns.board.id, socket.assigns.user)
  end

  def live_board_action(action, board_id, user) do
    {:ok, _} = LiveBoard.call(board_id, {:action, action, user: user})
  end

  def new_column_changeset do
    Column.changeset(%Column{}, %{})
  end

  def online_count(socket_or_board_id) do
    with map when is_map(map) <- online_users(socket_or_board_id) do
      map_size(map)
    end
  end

  def online_users(socket_or_board_id) do
    with topic when not is_nil(topic) <- BoardLive.topic(socket_or_board_id) do
      Presence.list(topic)
    end
  end

  def get_search_assign(q, _board) when q in ["", nil], do: nil

  def get_search_assign(%Search{q: q}, board), do: get_search_assign(q, board)

  def get_search_assign(q, board),
    do: %Search{q: q, board: Search.query(q, board)}

  def role_suggest_new, do: %RoleSuggest{}

  def role_suggest_debounce(nil, input) do
    role_suggest_debounce(%RoleSuggest{}, input)
  end

  def role_suggest_debounce(%RoleSuggest{timer: timer} = suggest, input)
      when not is_nil(timer) do
    Process.cancel_timer(timer)
    role_suggest_debounce(%{suggest | timer: nil}, input)
  end

  def role_suggest_debounce(%RoleSuggest{} = suggest, input) do
    timer =
      if String.length(input) >= 3 do
        Process.send_after(self(), :role_suggest_fire, @debounce_timeout)
      end

    %{suggest | q: input, timer: timer}
  end

  def role_suggest_run(%RoleSuggest{q: q} = suggest) do
    %{suggest | list: Account.suggest_users(q), timer: nil}
  end
end
