defmodule LucidboardWeb.PageControllerTest do
  @moduledoc false
  use LucidboardWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Lucidboard"
  end
end
