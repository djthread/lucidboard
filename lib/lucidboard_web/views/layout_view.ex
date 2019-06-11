defmodule LucidboardWeb.LayoutView do
  use LucidboardWeb, :view

  @doc "Render our outer-most wrapping"
  def render_layout(outer_layout, assigns, do: content) do
    render(outer_layout, Map.put(assigns, :inner_layout, content))
  end

  defp body_class(nil), do: "t-light"
  defp body_class(%{settings: %{theme: theme}}), do: "t-#{theme}"
end
