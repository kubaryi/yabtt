defmodule YaBTT.Query.Utils do
  @moduledoc false

  import Ecto.Query.API

  @doc false
  @spec case_then(term(), [{:do, term()} | {:else, term()}]) :: term()
  defmacro case_then(condition, clauses) do
    quote do
      fragment(unquote(build_query(condition, clauses)))
    end
  end

  defp build_query(condition, do: do_clause) do
    "CASE WHEN #{condition} THEN #{do_clause} END"
  end

  defp build_query(condition, do: do_clause, else: else_clause) do
    "CASE WHEN #{condition} THEN #{do_clause} ELSE #{else_clause} END"
  end

  @doc false
  @spec random :: term()
  defmacro random do
    quote do
      fragment("RANDOM()")
    end
  end
end
