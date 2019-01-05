defmodule LucidboardWeb.PageController do
  use LucidboardWeb, :controller
  alias LucidboardWeb.LayoutView

  def index(conn, _params) do
    render(conn, "index.html", layout: {LayoutView, :full_width})
  end
end
