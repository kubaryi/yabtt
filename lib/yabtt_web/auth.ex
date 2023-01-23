defmodule YaBTTWeb.Auth do
  @moduledoc """
  Plug for basic authentification.

  This Plug allows the client to authenticate with [RFC7617][rfc7617].

  Default authentication:

  - username: "admin"
  - password: "admin"

  ## Example

  You can import the module and use it by `plug`:

      import YaBTTWeb.Auth

      plug :auth, username: "admin", password: "admin"

  Or, use it as a Plug:

      plug YaBTTWeb.Auth, username: "admin", password: "admin"

  [rfc7617]: https://datatracker.ietf.org/doc/html/rfc7617
  """

  @behaviour Plug

  import Plug.BasicAuth

  @doc """
  Initializes the plug with the given options.
  """
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Authenticates the request when use this module as a Plug.

  ## Example

      plug YaBTTWeb.Auth
  """
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, opts \\ []), do: auth(conn, opts)

  @default_auth [username: "admin", password: "admin"]

  @doc """
  Returns the authentication configuration.

  priority: plug args > [environment](./readme.html#configuration) > [default](`YaBTTWeb.Auth`)
  """
  @spec auth_config(keyword()) :: keyword()
  def auth_config(opts) do
    Keyword.merge(Application.get_env(:yabtt, __MODULE__, @default_auth), opts)
  end

  @doc """
  Authenticates the request when use this module as a module.

  ## Example

      import YaBTTWeb.Auth

      plug :auth
  """
  @spec auth(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def auth(conn, opts), do: basic_auth(conn, auth_config(opts))
end
