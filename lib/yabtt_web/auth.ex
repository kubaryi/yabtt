defmodule YaBTTWeb.Auth do
  @moduledoc false

  @behaviour Plug

  import Plug.BasicAuth

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, opts \\ []), do: auth(conn, opts)

  @default_auth [username: "admin", password: "admin"]

  @spec auth_config(keyword()) :: keyword()
  def auth_config(opts) do
    Application.get_env(:yabtt, __MODULE__, Keyword.merge(@default_auth, opts))
  end

  @spec auth(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def auth(conn, opts), do: basic_auth(conn, auth_config(opts))
end
