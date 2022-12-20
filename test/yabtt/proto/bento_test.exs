defmodule YaBTT.Proto.BentoTest do
  use ExUnit.Case, async: true

  doctest Bento.Encoder.Tuple
  doctest Bento.Encoder.YaBTT.Proto.Response
  doctest Bento.Encoder.YaBTT.Proto.Peered
  doctest Bento.Encoder.YaBTT.Errors.InvalidRequeste
  doctest Bento.Encoder.YaBTT.Errors.Timeout
  doctest Bento.Encoder.YaBTT.Errors.Refused
end
