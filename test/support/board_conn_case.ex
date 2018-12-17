defmodule LucidboardWeb.BoardCase do
  @moduledoc """
  Inserts a board fixture record to the database in setup. The context
  includes the inserted board under the `:board` key.
  """
  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Lucidboard.{Repo, Seeds, Twiddler}

  using do
    quote do
      use ExUnit.Case
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    %{id: board_id} = Repo.insert!(Seeds.board())
    board = Twiddler.by_id(board_id)

    {:ok, board: board}
  end
end
