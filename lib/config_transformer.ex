defmodule ConfigTransformer do
  @moduledoc "Parses our toml config file for releases"
  use TomlTransformer, app_env_var: "LB_ENV"
end
