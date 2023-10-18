defmodule Suzy.Numbers do
  @moduledoc """
  The Numbers context.
  """
  alias Suzy.Number

  @max_number 100_000_000_000

  @type from :: integer()
  @type to :: integer()
  @type num :: Number.t() | integer()

  @doc """
  Returns a stream of number with attributes, given a number range and a runtime stack.

  The stack contains middleware modules implementating `c:Number.deduce/1` that are responsible
  for deducing various number attributes (e.g. mod-n) and recording results in the
  `attrs` list of the `t:Number.t/0` struct.`

  The default number range is 1 to 100. The range maximum is 100 billion.
  """
  @spec number_stream({from, to}, Number.stack()) ::
          {:ok, Enumerable.t()} | {:error, :num_out_of_range}
  def number_stream(num_range \\ {1, 100}, stack \\ [])

  def number_stream({from, to}, stack) when from > 0 and to <= @max_number do
    from..to
    |> Stream.map(fn num -> new(num, stack) |> deduce() end)
    |> then(fn stream -> {:ok, stream} end)
  end

  def number_stream(_, _), do: {:error, :num_out_of_range}

  @doc """
  Returns a `t:Number.t/0` struct given a integer value with a runtime stack.

  The (middleware modules) stack is responsible for number attributes deduction and
  contained in the `stack` field of the `t:Number.t/0` struct.`
  """
  @spec new(num(), Number.stack()) :: num()
  def new(number, stack \\ [])
  def new(integer, stack) when is_integer(integer), do: Number.new(integer) |> new(stack)
  def new(%Number{} = number, []), do: number
  def new(%Number{} = number, stack), do: number |> Number.new(stack)

  @doc """
  Invoke the runtime stack for number attributes deduction.

  The deduction results are contained in the `attrs` list of the `t:Number.t/0` struct.`
  """
  @spec deduce(num()) :: num()
  def deduce(%Number{} = number), do: number |> deduce(number.stack)
  def deduce(%Number{} = number, []), do: number
  def deduce(%Number{} = number, [h | rest]), do: h.deduce(number) |> deduce(rest)

  @doc false
  def max_number, do: @max_number
end
