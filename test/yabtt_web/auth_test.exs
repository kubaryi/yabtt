defmodule YaBTTWeb.AuthTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias YaBTTWeb.Auth

  @default_auth [username: "admin", password: "admin"]
  @test_auth [username: "only_for_test", password: "pa$$w0rd"]

  setup_all do
    [auth: Auth.init(@test_auth)]
  end

  test "Get the auth config", %{auth: auth} do
    assert @default_auth == Auth.auth_config([])
    assert @test_auth == Auth.auth_config(auth)

    Application.put_env(:yabtt, Auth, @test_auth)

    assert @test_auth == Auth.auth_config([])

    Application.delete_env(:yabtt, Auth)
  end
end
