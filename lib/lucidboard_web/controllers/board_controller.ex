defmodule LucidboardWeb.BoardController do
  use LucidboardWeb, :controller
  alias Lucidboard.{Account, LiveBoard}

  def dnd_into_junction(%{body_params: p} = conn, %{"id" => board_id}) do
    user = conn |> get_session(:user_id) |> Account.get!()

    args = %{
      id: p["what_id"],
      col_id: p["col_id"],
      pos: String.to_integer(p["pos"])
    }

    action =
      case p["what"] do
        "card" -> {:move_card_to_junction, args}
        "pile" -> {:move_pile_to_junction, args}
      end

    do_liveboard_action(board_id, action, user)

    resp(conn, 200, "ok")
  end

  # When a pile is dragged onto a pile, p["what"] is "pile", and we straight
  # ignore it. Unsupported action.
  def dnd_into_pile(%{body_params: p} = conn, %{"id" => board_id}) do
    user = conn |> get_session(:user_id) |> Account.get!()

    if "card" == p["what"] do
      action = {:move_card_to_pile, id: p["what_id"], pile_id: p["pile_id"]}
      do_liveboard_action(board_id, action, user)
    end

    resp(conn, 200, "ok")
  end

  defp do_liveboard_action(board_id, action, user) do
    msg = {:action, action, user: user}
    {:ok, _} = LiveBoard.call(String.to_integer(board_id), msg)
  end
end
