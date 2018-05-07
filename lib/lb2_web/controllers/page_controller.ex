defmodule Lb2Web.PageController do
  use Lb2Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
