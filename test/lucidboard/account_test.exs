defmodule Lucidboard.AccountTest do
  use ExUnit.Case
  import Lucidboard.Account
  alias Lucidboard.{Board, BoardRole, BoardSettings, User}

  test "has_role?: open boards are cool for non-owners" do
    assert has_role?(
             %User{},
             %Board{settings: %BoardSettings{access: :open}},
             :observer
           )

    assert has_role?(
             %User{},
             %Board{settings: %BoardSettings{access: :open}},
             :contributor
           )

    refute has_role?(
             %User{},
             %Board{settings: %BoardSettings{access: :open}, board_roles: []},
             :owner
           )
  end

  test "has_role?: public boards" do
    assert has_role?(
             %User{},
             %Board{settings: %BoardSettings{access: :public}},
             :observer
           )

    refute has_role?(
             %User{},
             %Board{settings: %BoardSettings{access: :public}, board_roles: []},
             :contributor
           )

    assert has_role?(
             %User{id: 2},
             %Board{
               settings: %BoardSettings{access: :public},
               board_roles: [%BoardRole{user_id: 2, role: :contributor}]
             },
             :contributor
           )

    refute has_role?(
             %User{id: 2},
             %Board{
               settings: %BoardSettings{access: :public},
               board_roles: [%BoardRole{user_id: 2, role: :contributor}]
             },
             :owner
           )
  end

  test "has_role?: private boards are restrictive" do
    refute has_role?(
             %User{},
             %Board{
               settings: %BoardSettings{access: :private},
               board_roles: []
             },
             :owner
           )

    refute has_role?(
             %User{id: 3},
             %Board{
               settings: %BoardSettings{access: :private},
               board_roles: [%BoardRole{user_id: 3, role: :contributor}]
             },
             :owner
           )

    assert has_role?(
             %User{id: 3},
             %Board{
               settings: %BoardSettings{access: :private},
               board_roles: [%BoardRole{user_id: 3, role: :owner}]
             },
             :owner
           )
  end
end
