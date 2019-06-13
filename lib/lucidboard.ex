defmodule Lucidboard do
  @moduledoc "A collaborative kanban tool!"
  alias Phoenix.PubSub

  @pubsub Lucidboard.PubSub
  @timezone Application.get_env(:lucidboard, :timezone)
  @datetime_format_short "%-m/%-d %l:%M %p"
  @datetime_format_long "%Y/%-m/%-d %l:%M %p"

  @doc false
  def subscribe(topic) do
    PubSub.subscribe(@pubsub, topic)
  end

  @doc false
  def broadcast(topic, message) do
    PubSub.broadcast(@pubsub, topic, message)
  end

  @doc """
  Convert a UTC DateTime to one for our time zone.

  Also, microsecond information is removed because Ecto doesn't want it.
  """
  @spec utc_to_local(DateTime.t()) :: DateTime.t()
  def utc_to_local(utc_datetime) do
    utc_datetime
    |> Timex.to_datetime(@timezone)
    |> DateTime.truncate(:second)
  end

  @spec utc_to_formatted(DateTime.t()) :: String.t()
  def utc_to_formatted(utc_datetime, mode \\ :short) do
    utc_datetime
    |> utc_to_local()
    |> format(mode)
  end

  def format(datetime, mode \\ :short)

  def format(datetime, :short),
    do: Timex.format!(datetime, @datetime_format_short, :strftime)

  def format(datetime, :long),
    do: Timex.format!(datetime, @datetime_format_long, :strftime)

  def auth_provider do
    :lucidboard
    |> Application.get_env(:auth_provider)
    |> String.to_atom()
end
