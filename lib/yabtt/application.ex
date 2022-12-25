defmodule YaBTT.Application do
  @moduledoc """
  The YaBTT application. This module is responsible for starting the
  application and supervising the application's processes.

  ## References

  * OTP Applications - https://hexdocs.pm/elixir/Application.html
  * Supervisor - https://hexdocs.pm/elixir/Supervisor.html
  """

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      YaBTT.Repo.child_spec([]),
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: YaBTT.Server.Router,
        port: Application.get_env(:yabtt, :port, 8080)
      )
    ]

    opts = [strategy: :one_for_one, name: YaBTT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
