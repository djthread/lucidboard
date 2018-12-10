defmodule LucidboardWeb.PageController do
  use LucidboardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
