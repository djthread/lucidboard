defmodule Lucidboard.Account.Github do
  @moduledoc "Logic specific to using Github as an auth provider"
  alias Lucidboard.User
  alias Ueberauth.Auth

  def to_user(%Auth{} = auth) do
    user =
      User.new(
        name: nickname_from_auth(auth),
        full_name: name_from_auth(auth)
      )

    {:ok, user}
  end

  defp nickname_from_auth(%{info: %{nickname: nickname}}), do: nickname

  defp name_from_auth(auth) do
    with nil <- Map.get(auth.info, :name) do
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      if Enum.empty?(name) do
        auth.info.nickname
      else
        Enum.join(name, " ")
      end
    end
  end
end
