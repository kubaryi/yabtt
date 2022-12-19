defmodule YaBTT.ErrorsTest do
  use ExUnit.Case, async: true

  doctest YaBTT.Errors.InvalidRequeste
  doctest YaBTT.Errors.Timeout
  doctest YaBTT.Errors.Refused
end
