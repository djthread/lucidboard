defmodule Lucidboard do
  @moduledoc "A collaborative kanban tool!"
  alias Phoenix.PubSub

  @pubsub Lucidboard.PubSub

  @doc false
  def subscribe(topic) do
    PubSub.subscribe(@pubsub, topic)
  end

  @doc false
  def broadcast(topic, message) do
    PubSub.broadcast(@pubsub, topic, message)
  end
end
