defmodule Yabtt.Types.Event do
  @moduledoc """
  A custom type for events.

  There are three available events: "started", "stopped", and "completed".

  The three events are represented by the following event codes:

  * "started" - 1
  * "stopped" - 0
  * "completed" - -1

  The event codes are stored in the database as integers.

  The load process converts the event code to the event.
  """

  use Ecto.Type

  @typedoc """
  The event type. The available events are "started", "stopped", and "completed".
  """
  @type event :: <<_::56, _::_*16>>

  @typedoc """
  The event code type. The available event codes are 1, 0, and -1.
  """
  @type io_event :: -1 | 0 | 1

  @doc """
  Returns the underlying schema type for the custom type.
  """
  @spec type :: :integer
  def type, do: :integer

  @doc """
  Casts the given value to an event (`t:event/0`).

  There are three available events: "started", "stopped", and "completed".

  ## Parameters

    * `event` - The event to cast. The event could be a binary(`t:event/0`).

  ## Examples

      iex> Yabtt.Types.Event.cast("started")
      {:ok, 1}

      iex> Yabtt.Types.Event.cast("stopped")
      {:ok, 0}

      iex> Yabtt.Types.Event.cast("completed")
      {:ok, -1}

      iex> Yabtt.Types.Event.cast("abc")
      :error

      iex> Yabtt.Types.Event.cast(:started)
      :error
  """
  @spec cast(event()) :: :error | {:ok, io_event()}
  def cast(event) when is_binary(event) do
    case event do
      "started" -> {:ok, 1}
      "stopped" -> {:ok, 0}
      "completed" -> {:ok, -1}
      _ -> :error
    end
  end

  def cast(_), do: :error

  @doc """
  Loads the given value from the database.

  The value is an integer, which is the event code(`t:io_event/0`).

  ## Parameters

    * `event` - The event code to load. The event code could be a integer(`t:io_event/0`).

  ## Examples

      iex> Yabtt.Types.Event.load(1)
      {:ok, "started"}

      iex> Yabtt.Types.Event.load(0)
      {:ok, "stopped"}

      iex> Yabtt.Types.Event.load(-1)
      {:ok, "completed"}

      iex> Yabtt.Types.Event.load(2)
      :error
  """
  @spec load(io_event()) :: :error | {:ok, event()}
  def load(1), do: {:ok, "started"}
  def load(0), do: {:ok, "stopped"}
  def load(-1), do: {:ok, "completed"}
  def load(_), do: :error

  @doc """
  Dumps the given value to the database.

  The value is an integer, which is the event code(`t:io_event/0`).

  ## Parameters

  * `event` - The event code to dump. The event code could be a integer(`t:io_event/0`).

  ## Examples

      iex> Yabtt.Types.Event.dump(1)
      {:ok, 1}

      iex> Yabtt.Types.Event.dump(0)
      {:ok, 0}

      iex> Yabtt.Types.Event.dump(-1)
      {:ok, -1}

      iex> Yabtt.Types.Event.dump(2)
      :error
  """
  @spec dump(io_event()) :: :error | {:ok, io_event()}
  def dump(1), do: {:ok, 1}
  def dump(0), do: {:ok, 0}
  def dump(-1), do: {:ok, -1}
  def dump(_), do: :error
end
