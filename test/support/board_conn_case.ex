defmodule LucidboardWeb.BoardConnCase do
  @moduledoc """
  Builds on `ConnCase` by inserting a board fixture record to the database
  first. The context includes the inserted board under the `:board` key.
  """
  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Lucidboard.{Repo, Seeds, Twiddler}
  alias Phoenix.ConnTest

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import LucidboardWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint LucidboardWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    %{id: board_id} = Repo.insert!(Seeds.board())
    board = Twiddler.by_id(board_id)

    {:ok, board: board, conn: ConnTest.build_conn()}
  end
end
