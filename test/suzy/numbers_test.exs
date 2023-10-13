defmodule Suzy.NumbersTest do
  use ExUnit.Case, async: true

  alias Suzy.Number
  alias Suzy.Numbers

  describe "number_stream/1" do
    test "with a num range" do
      assert {:ok, nums} = Numbers.number_stream({1, 3})
      assert [1, 2, 3] = nums |> Stream.map(fn %Number{value: num} -> num end) |> Enum.to_list()
    end

    test "default stream without a num range" do
      assert {:ok, nums} = Numbers.number_stream()

      nums = nums |> Enum.to_list()
      assert %Number{} = hd(nums)
      assert is_list(nums)
      assert nums |> length() != 0
    end

    test "when num out of range" do
      assert {:error, :num_out_of_range} = Numbers.number_stream({-1, 5})
      assert {:error, :num_out_of_range} = Numbers.number_stream({1, Numbers.max_number() + 1})
    end
  end

  test "max_number/0" do
    assert is_number(Numbers.max_number())
  end

  test "new/1" do
    assert %Number{value: 1, attrs: []} == Numbers.new(1)
  end

  test "deduce/1" do
    assert %Number{value: 1, attrs: []} == Numbers.new(1) |> Numbers.deduce()
  end
end
