defmodule YaBTT.Proto.BentoTest do
  use ExUnit.Case, async: true

  doctest Bento.Encoder.Tuple
  doctest Bento.Encoder.YaBTT.Proto.Response
  doctest Bento.Encoder.YaBTT.Proto.Peered
end
