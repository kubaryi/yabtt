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
  def init(arg \\ []) do
    children = [
      Plug.Cowboy.child_spec(cowboy_opts(arg))
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @cowboy_opts [plug: YaBTTWeb.Router]

  @spec cowboy_opts(keyword()) :: keyword()
  defp cowboy_opts(arg) do
    disable_https = Application.get_env(:yabtt, :disable_https, false)
    config_for_https = Application.get_env(:yabtt, __MODULE__, scheme: :http, port: 8080)
    config_for_http = [scheme: :http, port: Keyword.get(config_for_https, :port)]
    opts = @cowboy_opts ++ unless(disable_https, do: config_for_https, else: config_for_http)

    Keyword.merge(opts, arg)
  end
end
