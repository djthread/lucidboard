defmodule Lucidboard.Presence do
  @moduledoc "Lucidboard presence!"
  use Phoenix.Presence,
    otp_app: :lucidboard,
    pubsub_server: Lucidboard.PubSub
end
