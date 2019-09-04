defmodule Lucidboard.Twiddler do
  @moduledoc """
  A context for board operations
  """
  import Ecto.Query
  alias Ecto.Association.NotLoaded
  alias Ecto.Changeset
  alias Lucidboard.{Account, Board, BoardRole, Event, ShortBoard}
  alias Lucidboard.Repo
  alias Lucidboard.Twiddler.{Actions, Op}

  @type action :: {atom, keyword | map}
  @type meta :: map
  @type action_ok_or_error ::
          {:ok, Board.t(), function, meta, Event.t()} | {:error, String.t()}

  @spec act(Board.t(), action, keyword) :: action_ok_or_error
  def act(board, action, opts \\ [])

  def act(%Board{} = board, {action_name, args}, opts) when is_list(args) do
    act(board, {action_name, Enum.into(args, %{})}, opts)
  end

  def act(%Board{} = board, {action_name, args}, opts)
      when is_atom(action_name) and is_map(args) do
    with true <- function_exported?(Actions, action_name, 3) || :no_action,
         {:ok, _, _, _, _} = res <-
           apply(Actions, action_name, [board, args, opts]) do
      res
    else
      :unauthorized ->
        {:ok, board, nil, nil, nil}

      :noop ->
        {:ok, board, nil, nil, nil}

      :no_action ->
        IO.puts("Action not implemented: #{inspect(action_name)}")
        {:ok, board, nil, nil, nil}

      %Changeset{} = cs ->
        {:error, cs}
    end
  end

  @doc "Get a board by its id"
  @spec by_id(integer) :: Board.t() | nil
  def by_id(id) do
    board =
      Repo.one(
        from(board in Board,
          where: board.id == ^id,
          left_join: board_roles in assoc(board, :board_roles),
          left_join: role_users in assoc(board_roles, :user),
          left_join: columns in assoc(board, :columns),
          left_join: piles in assoc(columns, :piles),
          left_join: cards in assoc(piles, :cards),
          left_join: likes in assoc(cards, :likes),
          preload: [
            columns: {columns, piles: {piles, cards: {cards, likes: likes}}},
            board_roles: {board_roles, user: role_users}
          ]
        )
      )

    if board, do: sort_board(board), else: nil
  end

  @doc "Sort all the columns, piles, and cards by their `:pos` fields"
  @spec sort_board(Board.t()) :: Board.t()
  def sort_board(%Board{} = board) do
    cols =
      Enum.reduce(board.columns, [], fn col, acc_cols ->
        piles =
          Enum.reduce(col.piles, [], fn pile, acc_piles ->
            cards =
              pile.cards
              |> Enum.map(&Op.sort_likes/1)
              |> Enum.sort(&(&1.pos < &2.pos))

            [%{pile | cards: cards} | acc_piles]
          end)

        piles = Enum.sort(piles, &(&1.pos < &2.pos))
        [%{col | piles: piles} | acc_cols]
      end)

    cols = Enum.sort(cols, &(&1.pos < &2.pos))
    %{board | columns: cols}
  end

  @doc "Get a list of board records"
  @spec boards(integer, integer, String.t()) :: [Board.t()]
  def boards(user_id, page_index \\ 1, q \\ "") do
    {:ok, open_int} = BoardAccessEnum.dump(:open)
    {:ok, public_int} = BoardAccessEnum.dump(:public)
    user = Account.get!(user_id)

    base_query =
      from(b in Board,
        left_join: u in assoc(b, :user),
        as: :user,
        left_join: r in assoc(b, :board_roles),
        as: :role,
        where:
          ilike(b.title, ^"%#{q}%") or
            ilike(u.name, ^"%#{q}%") or
            ilike(u.full_name, ^"%#{q}%"),
        distinct: [desc: b.id],
        order_by: [desc: b.updated_at],
        preload: :user
      )

    query =
      if user.admin do
        base_query
      else
        from([base, user: u, role: r] in base_query,
          where:
            fragment(
              "?->>'access' = ? or ?->>'access' = ?",
              base.settings,
              ^to_string(open_int),
              base.settings,
              ^to_string(public_int)
            ) or
              r.user_id == ^user_id
        )
      end

    Repo.paginate(query, page: page_index)
  end

  @doc """
  Insert a board record

  Creates 2 records: the Board and the BoardRole for the creator
  """
  @spec insert(Board.t()) :: {:ok, Board.t()} | {:error, Changeset.t()}
  def insert(%Board{user: user, user_id: user_id} = board) do
    tx_fn = fn ->
      board_role = BoardRole.new(user_id: user_id || user.id, role: :owner)
      tail = with %NotLoaded{} <- board.board_roles, do: []

      %{board | board_roles: [board_role | tail]}
      |> Board.changeset()
      |> Repo.insert()
    end

    case Repo.transaction(tx_fn) do
      {:ok, {:error, %Changeset{} = cs}} ->
        {:error, cs}

      {:ok, {:ok, %Board{} = b}} ->
        Lucidboard.broadcast("short_boards", {:new, ShortBoard.from_board(b)})
        {:ok, Repo.preload(b, :user)}
    end
  end
end
