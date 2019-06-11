defmodule LucidboardWeb.ViewHelper do
  @moduledoc "Helper functions for all views"
  import Phoenix.HTML, only: [raw: 1]
  alias Lucidboard.Event

  @doc "Create a font-awesome icon by name"
  def fas(name, class \\ nil), do: fa("fas", name, class)

  def fab(name, class \\ nil), do: fa("fab", name, class)

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

  def display_date_time(datetime, mode \\ :short) do
    Lucidboard.utc_to_formatted(datetime, mode)
  end

  def display_event(%Event{
        inserted_at: inserted_at,
        user: %{name: name},
        desc: desc
      }) do
    raw("""
    #{display_date_time(inserted_at)} \
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

  def display_name(%{name: name, full_name: full_name} = _user) do
    "#{name} (#{full_name})"
  end

  def avatar(%{avatar_url: nil} = _user) do
    "user-circle" |> fas() |> raw()
  end

  def avatar(%{avatar_url: url}) do
    raw(~s[<div class="avatar" style="background-image:url('#{url}')"></div>])
  end
end
