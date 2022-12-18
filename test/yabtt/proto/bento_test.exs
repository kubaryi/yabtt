defmodule YaBTT.Proto.BentoTest do
  use ExUnit.Case, async: true

  doctest Bento.Encoder.Tuple
  doctest Bento.Encoder.YaBTT.Server.Resp
  doctest Bento.Encoder.YaBTT.Proto.Peered
end
