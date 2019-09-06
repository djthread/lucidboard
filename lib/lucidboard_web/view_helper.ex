defmodule LucidboardWeb.ViewHelper do
  @moduledoc "Helper functions for all views"
  import Phoenix.HTML
  alias Lucidboard.{BoardRole, Event}

  @doc "Create a font-awesome icon by name"
  def fas(name, class \\ nil), do: fa("fas", name, class)

  def fab(name, class \\ nil), do: fa("fab", name, class)

  @doc "Given a board access setting, return the icon HTML"
  def board_access_icon(type, class \\ nil)
  def board_access_icon("private", class), do: fas("lock", class)
  def board_access_icon("public", class), do: fas("eye", class)
  def board_access_icon(_, _), do: nil

  def show_card_count(column) do
    count =
      Enum.reduce(column.piles, 0, fn pile, acc ->
        acc + length(pile.cards)
      end)

    "#{count} card#{if count != 1, do: "s"}"
  end

  def card_body_size_by_copy(body) do
    chars = String.length(body)

    cond do
      chars < 20 -> "3"
      chars < 50 -> "4"
      true -> "5"
    end
  end

  def display_event(%Event{
        inserted_at: inserted_at,
        user: %{name: name},
        desc: desc
      }) do
    raw("""
    #{Lucidboard.utc_to_formatted(inserted_at)} \
    <strong>#{name}</strong> \
    #{desc}\
    """)
  end

  defp fa(family, name, class) do
    extra = if is_nil(class), do: [], else: [class]
    full_class = Enum.join(["icon"] ++ extra, " ")

    raw("""
    <span class="#{full_class}">
      <i class="#{family} fa-#{name}"></i>
    </span>
    """)
  end

  def avatar(%{avatar_url: nil} = _user) do
    "user-circle" |> fas() |> raw()
  end

  def avatar(%{avatar_url: url}) do
    raw("""
    <div class="lb-icon-avatar" style="background-image:url('#{url}')"></div>\
    """)
  end

  @spec more_than_one_owner([BoardRole.t()]) :: boolean
  def more_than_one_owner(roles) do
    true ==
      Enum.reduce_while(roles, 0, fn
        %{role: :owner}, 1 -> {:halt, true}
        %{role: :owner}, acc -> {:cont, acc + 1}
        _, acc -> {:cont, acc}
      end)
  end

  def login_button do
    raw(
      case Lucidboard.auth_provider() do
        :dumb ->
          ~E"""
          <a class="button lb-button is-primary" href="/signin">
            <span>Sign in</span>
          </a>
          """

        :github ->
          ~E"""
          <a class="button lb-button is-primary" href="/auth/github">
            <span>Sign in with GitHub</span>
          </a>
          """

        :pingfed ->
          ~E"""
          <a class="button lb-button is-primary" href="/auth/pingfed">
            <span>Sign in with PingFed</span>
          </a>
          """
      end
    )
  end
end
