defmodule Lucidboard.Presence do
  @moduledoc "Lucidboard presence!"
  use Phoenix.Presence,
    otp_app: :lucidboard,
    pubsub_server: Lucidboard.PubSub

  @spec get_for_session(String.t(), integer | String.t(), String.t(), String.t()) :: any()
  def get_for_session(topic, user_id, lv_ref, key) do
    with user_id <- to_string(user_id),
         list <- list(topic),
         {:ok, %{metas: metas}} <- Map.fetch(list, user_id),
         meta when not is_nil(meta) <-
           Enum.find(metas, fn m -> m.lv_ref == lv_ref end) do
      Map.get(meta, key)
    end
  end
end
