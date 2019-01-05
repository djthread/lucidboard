defmodule LucidboardWeb.BoardController do
  use LucidboardWeb, :controller
  alias Lucidboard.Twiddler

  action_fallback LucidboardWeb.FallbackController

  def index(conn, %{"id" => board_id}) do
    case Twiddler.by_id(board_id) do
      nil -> {:error, :not_found}
      board -> render(conn, "index.html", board: board)
    end
  end
end
