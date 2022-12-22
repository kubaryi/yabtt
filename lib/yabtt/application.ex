defmodule YaBTT.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: YaBTT.Worker.start_link(arg)
      # {YaBTT.Worker, arg}
      YaBTT.Repo.child_spec([]),
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: YaBTT.Server.Router,
        port: Application.get_env(:yabtt, :port, 8080)
      ),
      YaBTT.Database.Cache.child_spec([])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YaBTT.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
