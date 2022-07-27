defmodule TreeExplorer.Repo do
  use Ecto.Repo,
    otp_app: :tree_explorer,
    adapter: Ecto.Adapters.Postgres
end
