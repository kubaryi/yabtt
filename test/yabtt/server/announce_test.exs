defmodule YaBTT.Server.AnnounceTest do
  use ExUnit.Case
  use Plug.Test

  doctest YaBTT.Server.Announce

  alias YaBTT.Server.Announce

  @default_params %{
    "info_hash" =>
      "\xf0\xa1\x5e\x27\xfa\xfb\xff\xc1\xc2\xf1\x8f\x69\xfc\xac\x2d\xfa\x46\x1f\xf4\xe8",
    "peer_id" => "-TR14276775888084598",
    "downloaded" => "0",
    "uploaded" => "0",
    "left" => "100",
    "event" => "started",
    "port" => "6881"
  }
  @default_resp_body "d8:intervali3600e5:peersld2:ip9:127.0.0.17:peer id20:-TR142767758880845984:porti6881eeee"

  setup_all do
    {:ok, Announce.init([])}
  end

  test "announce", opts do
    conn = conn(:get, "/announce", @default_params) |> Announce.call(opts)
    [content_type | _tail] = get_resp_header(conn, "content-type")

    assert conn.resp_body == @default_resp_body
    assert content_type == "plain/text; charset=utf-8"
    assert conn.state == :sent
    assert conn.status == 200
  end
end
