defmodule Listify.Repo do
  use Ecto.Repo,
    otp_app: :listify,
    adapter: Ecto.Adapters.Postgres
end
