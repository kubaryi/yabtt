defmodule YaBTT.Types.Event do
  @moduledoc """
  A custom type for events.

  There are three available events: `"started"`, `"stopped"`, and `"completed"`.

  The three events will be `cast/1` to theirs atomic types: `:started`,
  `:stopped`, and `:completed`. Then, the atomic event will be `dump/1` to
  database with their event codes: `1`, `0`, and `-1`.

  | EVENT         | ATOMIC EVENT | EVENT CODE |
  | ------------- | ------------ | ---------- |
  | `"started"`   | `:started`   | `1`        |
  | `"stopped"`   | `:stopped`   | `0`        |
  | `"completed"` | `:completed` | `-1`       |

  The `load/1` process converts the event code to the atomic event.
  """

  use Ecto.Type

  @typedoc """
  The atomic event type. Available with: `:started`, `:stopped`, and `:completed`.

  Learn more about [the relation between the event, atomic event, and event code](`YaBTT.Types.Event`)
  """
  @type event :: :started | :stopped | :completed

  @typedoc """
  The event code type. Available with: -1, 0, and 1.

  Learn more about [the relation between the event, atomic event, and event code](`YaBTT.Types.Event`)
  """
  @type io_event :: -1 | 0 | 1

  @doc """
  Returns the underlying schema type for the custom type.
  """
  @spec type :: :integer
  def type, do: :integer

  @doc """
  Casts the given value to an event (`t:event/0`).

  There are three available value: `"started"`, `"stopped"`, and `"completed"`.

  The three values will be cast to their atomic types: `:started`, `:stopped`,
  and `:completed`. The other values will be cast to `:error`.

  ## Parameters

    * `event` - The event to cast. The event could be a binary.

  ## Examples

      iex> YaBTT.Types.Event.cast("started")
      {:ok, :started}

      iex> YaBTT.Types.Event.cast("stopped")
      {:ok, :stopped}

      iex> YaBTT.Types.Event.cast("completed")
      {:ok, :completed}

      iex> YaBTT.Types.Event.cast("abc")
      :error

      iex> YaBTT.Types.Event.cast(:started)
      :error
  """
  @spec cast(binary()) :: :error | {:ok, event()}
  def cast(event) when event == "started", do: {:ok, :started}
  def cast(event) when event == "stopped", do: {:ok, :stopped}
  def cast(event) when event == "completed", do: {:ok, :completed}
  def cast(_), do: :error

  @doc """
  Loads the given value from the database.

  The value is an event code(`t:io_event/0`).

  ## Parameters

    * `event` - The event code(`t:io_event/0`) to load.

  ## Examples

      iex> YaBTT.Types.Event.load(1)
      {:ok, :started}

      iex> YaBTT.Types.Event.load(0)
      {:ok, :stopped}

      iex> YaBTT.Types.Event.load(-1)
      {:ok, :completed}

      iex> YaBTT.Types.Event.load(2)
      :error
  """
  @spec load(io_event()) :: :error | {:ok, event()}
  def load(1), do: {:ok, :started}
  def load(0), do: {:ok, :stopped}
  def load(-1), do: {:ok, :completed}
  def load(_), do: :error

  @doc """
  Dumps the given value to the database.

  The value is an atomic event(`t:event/0`).

  ## Parameters

  * `event` - The atomic event(`t:event/0`) to dump.

  ## Examples

      iex> YaBTT.Types.Event.dump(:started)
      {:ok, 1}

      iex> YaBTT.Types.Event.dump(:stopped)
      {:ok, 0}

      iex> YaBTT.Types.Event.dump(:completed)
      {:ok, -1}

      iex> YaBTT.Types.Event.dump(:other)
      :error
  """
  @spec dump(event()) :: :error | {:ok, io_event()}
  def dump(:started), do: {:ok, 1}
  def dump(:stopped), do: {:ok, 0}
  def dump(:completed), do: {:ok, -1}
  def dump(_), do: :error
end
