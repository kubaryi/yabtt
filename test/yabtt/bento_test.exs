defmodule YaBTT.BentoTest do
  use ExUnit.Case, async: true

  doctest Bento.Encoder.Tuple
  doctest Bento.Encoder.YaBTT.Peered
end
