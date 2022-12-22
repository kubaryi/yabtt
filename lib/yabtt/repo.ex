defmodule YaBTT.Repo do
  use Ecto.Repo,
    otp_app: :yabtt,
    adapter: Ecto.Adapters.Postgres
end
