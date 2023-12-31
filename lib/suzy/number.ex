defmodule Suzy.Number do
  @moduledoc """
  Behaviour and struct of a number.

  This behaviour and default implementation forms a basis for
  other number implementations that deduce various attributes
  belonging to a number e.g. "modulo-n", "prime" etc.
  """

  @derive {Jason.Encoder, only: [:value, :attrs, :cached]}
  defstruct value: 1,
            attrs: [],
            stack: [],
            status: nil,
            cached: false,
            __cache_server__: Suzy.Cache.Server

  @type t :: %__MODULE__{
          value: integer(),
          attrs: list(atom()),
          stack: list(module()),
          status: status(),
          cached: boolean(),
          __cache_server__: module()
        }

  @type status :: nil | {:ok, :from_cache} | {:ok, :cached} | {:error, term()}

  @typedoc """
  List of number attributes represented as atomic output from `c:deduce/1`.
  """
  @type attrs :: list(atom())

  @typedoc """
  Number struct containing the number value, attributes and a stack of the `Number`
  behaviour implementations.
  """
  @type num :: __MODULE__.t()

  @typedoc """
  A stack of implementations of the `Number` behaviour.
  """
  @type stack :: list(module())

  @doc """
  Invoked to deduce a number-related attribute.

  For example checking if a number is even or "modulo-2"
  and recording the result (currently as atom), `:mod_2`
  in `attrs` list of the `t:Suzy.Number.t/0` struct.
  """
  @callback deduce(num()) :: num()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      import unquote(__MODULE__)

      # base implementation simply performs no deduction
      @impl true
      def deduce(number), do: number
      defoverridable deduce: 1
    end
  end

  @doc """
  Initialises a Number struct containing an integer value.
  """
  @spec new(integer()) :: num()
  def new(integer \\ 1), do: %__MODULE__{value: integer}

  @doc """
  Adds implementations onto the Number stack.
  """
  @spec new(num(), module() | stack()) :: num()
  def new(number, [impl | t]) when is_atom(impl), do: %{number | stack: [impl | t]}
  def new(number, impl) when is_atom(impl), do: %{number | stack: [impl | number.stack]}
end
