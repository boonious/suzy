defmodule Suzy.Numbers do
  @moduledoc """
  The Numbers context.
  """

  @max_number 100_000_000_000

  @type from :: integer()
  @type to :: integer()

  @doc """
  Returns a number stream of a given range.

  The default number range is 1 to 100. The range maximum is 100 billionth.
  """
  @spec number_stream({from, to}) :: {:ok, Range.t()} | {:error, :num_out_of_range}
  def number_stream(num_range \\ {1, 100})

  def number_stream({from, to}) when from > 0 and to <= @max_number do
    {:ok, from..to}
  end

  def number_stream(_), do: {:error, :num_out_of_range}

  @doc false
  def max_number, do: @max_number
end
