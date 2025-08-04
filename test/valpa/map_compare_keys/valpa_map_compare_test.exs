defmodule Valpa.ValpaMapCompareTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Valpa.Predicate.Validator, as: Predicate

  defp ok(va) do
    {:ok, va}
  end

  defp error(validator, value, criteria) do
    {:error,
     Valpa.Error.new(%{
       validator: validator,
       value: value,
       field: nil,
       criteria: criteria
     })}
  end

  def assert_error({:error, left}, {:error, right}) do
    assert Map.delete(left, :__trace__) == Map.delete(right, :__trace__)
  end

  describe "map_compare_int_keys/2 and maybe_map_compare_int_keys/2" do
    @valid [
      {%{a: 1, b: 2}, {:<, :a, :b}},
      {%{a: 5, b: 5}, {:==, :a, :b}},
      {%{a: 10, b: 2}, {:>, :a, :b}},
      {%{a: 5, b: 5}, {:>=, :a, :b}},
      {%{a: 4, b: 5}, {:<=, :a, :b}},
      {%{a: 4, b: 5}, {:!=, :a, :b}},
      # nil or missing fields
      {%{a: nil, b: 2}, {:<, :a, :b}},
      {%{a: 1, b: nil}, {:<, :a, :b}},
      {%{a: nil, b: nil}, {:<, :a, :b}},
      {%{a: 5}, {:<, :a, :b}},
      {%{}, {:<, :a, :b}}
    ]

    @invalid [
      {%{a: 3, b: 2}, {:<, :a, :b}},
      {%{a: 2, b: 2}, {:<, :a, :b}},
      {%{a: 2, b: 2}, {:!=, :a, :b}},
      {%{a: 1, b: 2}, {:>, :a, :b}},
      {%{a: 3, b: 5}, {:==, :a, :b}},
      # not integer
      {%{a: 1.0, b: 2}, {:<, :a, :b}},
      {%{a: 1, b: 2.0}, {:<, :a, :b}},
      {%{a: Decimal.new("1"), b: 2}, {:<, :a, :b}},
      {%{a: 1, b: Decimal.new("2")}, {:<, :a, :b}},
      {%{a: "1", b: 2}, {:<, :a, :b}},
      {%{a: 1, b: "2"}, {:<, :a, :b}},
      {%{a: true, b: 1}, {:<, :a, :b}},
      {%{a: 1, b: false}, {:<, :a, :b}}
    ]

    @maybe_valid [{nil, {:>, :a, :b}} | @valid]

    test "predicate: map_compare_int_keys returns true when integer comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Predicate.map_compare_int_keys(input, criteria) == true)
    end

    test "predicate: map_compare_int_keys returns false when integer comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.map_compare_int_keys(input, criteria) == false)
    end

    test "predicate: maybe_map_compare_int_keys returns true when integer comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Predicate.maybe_map_compare_int_keys(input, criteria) == true)
    end

    test "predicate: maybe_map_compare_int_keys returns false when integer comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.maybe_map_compare_int_keys(input, criteria) == false)
    end

    test "predicate: raises or fails for unsupported operator" do
      assert_raise FunctionClauseError, fn ->
        Predicate.map_compare_int_keys(%{a: 1, b: 2}, {:invalid_op, :a, :b})
      end

      assert_raise FunctionClauseError, fn ->
        Predicate.maybe_map_compare_int_keys(%{a: 1, b: 2}, {:invalid_op, :a, :b})
      end
    end

    test "map_compare_int_keys returns {:ok, input} when integer comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Valpa.map_compare_int_keys(input, criteria) == ok(input))
    end

    test "map_compare_int_keys returns {:error, reason} when integer comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.map_compare_int_keys(input, criteria),
              error(:map_compare_int_keys, input, criteria)
            )
    end

    test "maybe_map_compare_int_keys returns {:ok, input} when integer comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Valpa.maybe_map_compare_int_keys(input, criteria) == ok(input))
    end

    test "maybe_map_compare_int_keys returns {:error, reason} when integer comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.maybe_map_compare_int_keys(input, criteria),
              error(:maybe_map_compare_int_keys, input, criteria)
            )
    end
  end

  describe "map_compare_float_keys/2 and maybe_map_compare_float_keys/2" do
    @valid [
      {%{a: 1.0, b: 2.0}, {:<, :a, :b}},
      {%{a: 5.5, b: 5.5}, {:==, :a, :b}},
      {%{a: 10.1, b: 2.5}, {:>, :a, :b}},
      {%{a: 5.0, b: 5.0}, {:>=, :a, :b}},
      {%{a: 4.5, b: 5.0}, {:<=, :a, :b}},
      {%{a: 4.2, b: 5.1}, {:!=, :a, :b}},
      # nil or missing fields
      {%{a: nil, b: 2.0}, {:<, :a, :b}},
      {%{a: 1.0, b: nil}, {:<, :a, :b}},
      {%{a: nil, b: nil}, {:<, :a, :b}},
      {%{a: 5.4}, {:<, :a, :b}},
      {%{}, {:<, :a, :b}}
    ]

    @invalid [
      {%{a: 3.5, b: 2.5}, {:<, :a, :b}},
      {%{a: 2.0, b: 2.0}, {:<, :a, :b}},
      {%{a: 2.0, b: 2.0}, {:!=, :a, :b}},
      {%{a: 1.0, b: 2.0}, {:>, :a, :b}},
      {%{a: 3.1, b: 5.9}, {:==, :a, :b}},
      # wrong type
      {%{a: 1, b: 2.0}, {:<, :a, :b}},
      {%{a: 1.0, b: 2}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0"), b: 2.0}, {:<, :a, :b}},
      {%{a: 1.0, b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: "1.0", b: 2.0}, {:<, :a, :b}},
      {%{a: 1.0, b: "2.0"}, {:<, :a, :b}},
      {%{a: 1, b: 1.0}, {:==, :a, :b}},
      {%{a: 1.0, b: false}, {:<, :a, :b}}
    ]

    @maybe_valid [{nil, {:>, :a, :b}} | @valid]

    test "predicate: map_compare_float_keys returns true when float comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Predicate.map_compare_float_keys(input, criteria) == true)
    end

    test "predicate: map_compare_float_keys returns false when float comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.map_compare_float_keys(input, criteria) == false)
    end

    test "predicate: maybe_map_compare_float_keys returns true when float comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Predicate.maybe_map_compare_float_keys(input, criteria) == true)
    end

    test "predicate: maybe_map_compare_float_keys returns false when float comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.maybe_map_compare_float_keys(input, criteria) == false)
    end

    test "predicate: raises or fails for unsupported operator" do
      assert_raise FunctionClauseError, fn ->
        Predicate.map_compare_float_keys(%{a: 1.3, b: 2.4}, {:invalid_op, :a, :b})
      end

      assert_raise FunctionClauseError, fn ->
        Predicate.maybe_map_compare_float_keys(
          %{a: 1.4, b: 2.5},
          {:invalid_op, :a, :b}
        )
      end
    end

    test "map_compare_float_keys returns {:ok, input} when float comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Valpa.map_compare_float_keys(input, criteria) == ok(input))
    end

    test "map_compare_float_keys returns {:error, reason} when float comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.map_compare_float_keys(input, criteria),
              error(:map_compare_float_keys, input, criteria)
            )
    end

    test "maybe_map_compare_float_keys returns {:ok, input} when float comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Valpa.maybe_map_compare_float_keys(input, criteria) == ok(input))
    end

    test "maybe_map_compare_float_keys returns {:error, reason} when float comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.maybe_map_compare_float_keys(input, criteria),
              error(:maybe_map_compare_float_keys, input, criteria)
            )
    end
  end

  describe "map_compare_decimal_keys/2 and maybe_map_compare_decimal_keys/2" do
    @valid [
      {%{a: Decimal.new("1.0"), b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: Decimal.new("5.5"), b: Decimal.new("5.5")}, {:<=, :a, :b}},
      {%{a: Decimal.new("10.1"), b: Decimal.new("2.5")}, {:>, :a, :b}},
      {%{a: Decimal.new("5.0"), b: Decimal.new("5.0")}, {:>=, :a, :b}},
      {%{a: Decimal.new("4.5"), b: Decimal.new("5.0")}, {:!=, :a, :b}},
      {%{a: Decimal.new("4.2"), b: Decimal.new("4.2")}, {:==, :a, :b}},
      {%{a: Decimal.new("-10.1"), b: Decimal.new("-2.5")}, {:<, :a, :b}},
      # nil or missing fields
      {%{a: nil, b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0"), b: nil}, {:<, :a, :b}},
      {%{a: nil, b: nil}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0")}, {:<, :a, :b}},
      {%{}, {:<, :a, :b}}
    ]

    @invalid [
      {%{a: Decimal.new("3.5"), b: Decimal.new("2.5")}, {:<, :a, :b}},
      {%{a: Decimal.new("2.0"), b: Decimal.new("2.0")}, {:!=, :a, :b}},
      {%{a: Decimal.new("2.0"), b: Decimal.new("2.0")}, {:>, :a, :b}},
      {%{a: Decimal.new("1.0"), b: Decimal.new("2.0")}, {:==, :a, :b}},
      {%{a: Decimal.new("3.1"), b: Decimal.new("5.9")}, {:>=, :a, :b}},
      {%{a: Decimal.new("2.0"), b: Decimal.new("1.4")}, {:<=, :a, :b}},
      # wrong type
      {%{a: 1.0, b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0"), b: 2.0}, {:<, :a, :b}},
      {%{a: 1, b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0"), b: 2}, {:<, :a, :b}},
      {%{a: "1.0", b: Decimal.new("2.0")}, {:<, :a, :b}},
      {%{a: Decimal.new("1.0"), b: "2.0"}, {:<, :a, :b}},
      {%{a: 1, b: Decimal.new("1.0")}, {:==, :a, :b}},
      {%{a: Decimal.new("1.0"), b: false}, {:<, :a, :b}}
    ]

    @maybe_valid [{nil, {:>, :a, :b}} | @valid]

    test "predicate: map_compare_decimal_keys returns true when decimal comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Predicate.map_compare_decimal_keys(input, criteria) == true)
    end

    test "predicate: map_compare_decimal_keys returns false when decimal comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.map_compare_decimal_keys(input, criteria) == false)
    end

    test "predicate: maybe_map_compare_decimal_keys returns true when decimal comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Predicate.maybe_map_compare_decimal_keys(input, criteria) == true)
    end

    test "predicate: maybe_map_compare_decimal_keys returns false when decimal comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do: assert(Predicate.maybe_map_compare_decimal_keys(input, criteria) == false)
    end

    test "predicate: raises or fails for unsupported operator" do
      assert_raise FunctionClauseError, fn ->
        Predicate.map_compare_decimal_keys(
          %{a: Decimal.new("1.0"), b: Decimal.new("2.0")},
          {:invalid_op, :a, :b}
        )
      end

      assert_raise FunctionClauseError, fn ->
        Predicate.maybe_map_compare_decimal_keys(
          %{a: Decimal.new("1.0"), b: Decimal.new("2.0")},
          {:invalid_op, :a, :b}
        )
      end
    end

    test "map_compare_decimal_keys returns {:ok, input} when decimal comparison holds" do
      for vc <- @valid,
          {input, criteria} = vc,
          do: assert(Valpa.map_compare_decimal_keys(input, criteria) == ok(input))
    end

    test "map_compare_decimal_keys returns {:error, reason} when decimal comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.map_compare_decimal_keys(input, criteria),
              error(:map_compare_decimal_keys, input, criteria)
            )
    end

    test "maybe_map_compare_decimal_keys returns {:ok, input} when decimal comparison holds" do
      for mvc <- @maybe_valid,
          {input, criteria} = mvc,
          do: assert(Valpa.maybe_map_compare_decimal_keys(input, criteria) == ok(input))
    end

    test "maybe_map_compare_decimal_keys returns {:error, reason} when decimal comparison fails" do
      for ic <- @invalid,
          {input, criteria} = ic,
          do:
            assert_error(
              Valpa.maybe_map_compare_decimal_keys(input, criteria),
              error(:maybe_map_compare_decimal_keys, input, criteria)
            )
    end
  end
end
