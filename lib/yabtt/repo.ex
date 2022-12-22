defmodule YaBTT.Repo do
  use Ecto.Repo,
    otp_app: :yabtt,
    adapter: Ecto.Adapters.SQLite3
end
