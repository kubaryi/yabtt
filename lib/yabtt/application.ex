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
      Plug.Cowboy.child_spec(cowboy_opts(plug: YaBTT.Server.Router))
    ]

    opts = [strategy: :one_for_one, name: YaBTT.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp cowboy_opts(opts) do
    disable_https = Application.get_env(:yabtt, :disable_https, false)
    config_for_https = Application.get_env(:yabtt, Plug.Cowboy, scheme: :http, port: 8080)
    config_for_http = [scheme: :http, port: Keyword.get(config_for_https, :port, 8080)]

    unless(disable_https, do: config_for_https, else: config_for_http) ++ opts
  end
end
