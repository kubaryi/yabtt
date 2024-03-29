defmodule YaBTT.Application do
  @moduledoc false

  # References
  #   - https://hexdocs.pm/elixir/OTP%20Applications.html
  #   - https://hexdocs.pm/elixir/Supervisor.html

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      YaBTT.Repo.child_spec([]),
      YaBTTWeb.child_spec([])
    ]

    opts = [strategy: :one_for_one, name: YaBTT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
