defmodule YaBTTWeb do
  @moduledoc false

  use Supervisor

  @type init_option :: Supervisor.init_option()
  @type child_spec :: Supervisor.child_spec()

  @spec start_link(init_option()) :: Supervisor.on_start()
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  @spec init(keyword()) :: {:ok, {sup_flags, [child_spec]}}
        when child_spec: child_spec() | :supervisor.child_spec(),
             sup_flags: Supervisor.sup_flags()
  def init(arg) do
    Supervisor.init([child_spec(arg)], strategy: :one_for_one)
  end

  @cowboy_opts [plug: YaBTTWeb.Router]

  @spec child_spec(keyword()) :: child_spec()
  def child_spec(arg) do
    disable_https = Application.get_env(:yabtt, :disable_https, false)
    config_for_https = Application.get_env(:yabtt, Plug.Cowboy, scheme: :http, port: 8080)
    config_for_http = [scheme: :http, port: Keyword.get(config_for_https, :port, 8080)]
    opts = unless(disable_https, do: config_for_https, else: config_for_http) ++ @cowboy_opts

    Plug.Cowboy.child_spec(Keyword.merge(opts, arg))
  end
end
