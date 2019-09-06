defmodule LucidboardWeb.ViewHelperTest do
  use ExUnit.Case
  alias Lucidboard.BoardRole
  alias LucidboardWeb.ViewHelper

  test "more_than_one_owner?" do
    assert false == ViewHelper.more_than_one_owner?([])

    assert true ==
             ViewHelper.more_than_one_owner?([
               %BoardRole{board_id: 1, user_id: 1, role: :observer},
               %BoardRole{board_id: 1, user_id: 2, role: :owner},
               %BoardRole{board_id: 1, user_id: 3, role: :owner}
             ])

    assert false ==
             ViewHelper.more_than_one_owner?([
               %BoardRole{board_id: 1, user_id: 1, role: :observer},
               %BoardRole{board_id: 1, user_id: 2, role: :owner}
             ])
  end

  # @spec more_than_one_owner([BoardRole.t()]) :: boolean
  # def more_than_one_owner(roles) do
  #   true ==
  #     Enum.reduce_while(roles, 0, fn
  #       %{type: :owner}, 1 -> {:halt, true}
  #       %{type: :owner}, acc -> {:cont, acc + 1}
  #       _, acc -> {:cont, acc}
  #     end)
  # end
end
