defmodule LucidboardWeb.LiveHelper do
  @moduledoc """
  Some functionality to share between all Lucidboard LiveViews
  """
  import Phoenix.LiveView, only: [assign: 3]
  alias Phoenix.LiveView.Socket

  @flash_timeout 5_000

  defmacro __using__(_args) do
    quote do
      import unquote(__MODULE__), only: [put_the_flash: 3]
      import Phoenix.LiveView, only: [assign: 3]

      def handle_info(:clear_flash, socket) do
        {:noreply,
         socket |> assign(:flash_type, nil) |> assign(:flash_msg, nil)}
      end
    end
  end

  @spec put_the_flash(Socket.t(), :info | :error, String.t()) :: Socket.t()
  def put_the_flash(%Socket{} = socket, type, msg)
      when type in [:info, :error] do
    Process.send_after(self(), :clear_flash, @flash_timeout)

    socket
    |> assign(:flash_type, type)
    |> assign(:flash_msg, msg)
  end
end
