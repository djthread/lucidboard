defmodule Lucidboard.TimeMachine do
  @moduledoc "Manages Events"
  import Ecto.Query
  alias Lucidboard.{Event, Repo}

  @page_size 40

  def page_size, do: @page_size

  def events(board_id, opts \\ []) do
    size = Keyword.get(opts, :size, @page_size)
    page = Keyword.get(opts, :page, 1)

    Repo.all(
      from(e in Event,
        preload: [:user],
        where: e.board_id == ^board_id,
        order_by: [desc: e.inserted_at],
        limit: ^size,
        offset: ^((page - 1) * size)
      )
    )
  end

  def commit(%Event{} = event) do
    %{event | board_id: event.board.id, user_id: event.user.id}
    |> Repo.insert()
  end
end
