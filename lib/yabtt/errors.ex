defmodule YaBTT.Errors.InvalidRequeste do
  @moduledoc """
  This Exception for invalid request.

  ## Example

      iex> raise YaBTT.Errors.InvalidRequeste
      ** (YaBTT.Errors.InvalidRequeste) invalid request
  """

  defexception message: "invalid request"
end

defmodule YaBTT.Errors.Timeout do
  @moduledoc """
  This Exception for request timeout.

  ## Example

      iex> raise YaBTT.Errors.Timeout
      ** (YaBTT.Errors.Timeout) operation timed out
  """

  defexception message: "operation timed out"
end

defmodule YaBTT.Errors.Refused do
  @moduledoc """
  This Exception for connection refused.

  ## Example

      iex> raise YaBTT.Errors.Refused
      ** (YaBTT.Errors.Refused) connection refused
  """

  defexception message: "connection refused"
end
