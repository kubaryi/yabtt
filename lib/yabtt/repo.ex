defmodule YaBTT.Repo do
  @moduledoc """
  The repository for the YaBTT application.
  """

  use Ecto.Repo,
    otp_app: :yabtt,
    adapter: Ecto.Adapters.SQLite3
end
