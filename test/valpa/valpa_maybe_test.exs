defmodule Valpa.ValpaMaybeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  defp ok(va) do
    {:ok, va}
  end

  defp error(validator, value, criteria \\ nil) do
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

  describe "type validations" do
    test "integer/1" do
      va = 42
      assert Valpa.maybe_integer(va) == ok(va)
      va = nil
      assert Valpa.maybe_integer(va) == ok(va)
      assert_error(Valpa.maybe_integer("42"), error(:maybe_integer, "42", nil))
    end

    test "float/1" do
      va = 3.14
      assert Valpa.maybe_float(va) == ok(va)
      va = nil
      assert Valpa.maybe_float(va) == ok(va)
      assert_error(Valpa.maybe_float(42), error(:maybe_float, 42, nil))
    end

    test "string/1" do
      va = "hello"
      assert Valpa.maybe_string(va) == ok(va)
      va = nil
      assert Valpa.maybe_string(va) == ok(va)
      assert_error(Valpa.maybe_string(123), error(:maybe_string, 123, nil))
    end

    test "boolean/1" do
      va = true
      assert Valpa.maybe_boolean(va) == ok(va)
      va = false
      assert Valpa.maybe_boolean(va) == ok(va)
      va = nil
      assert Valpa.maybe_boolean(va) == ok(va)
      assert_error(Valpa.maybe_boolean(1), error(:maybe_boolean, 1, nil))
    end

    test "list/1" do
      va = [1, 2, 3]
      assert Valpa.maybe_list(va) == ok(va)
      va = nil
      assert Valpa.maybe_list(va) == ok(va)
      assert_error(Valpa.maybe_list(123), error(:maybe_list, 123, nil))
    end

    test "uniq_list/1" do
      va = [1, 2, 3]
      assert Valpa.maybe_uniq_list(va) == ok(va)
      va = nil
      assert Valpa.maybe_uniq_list(va) == ok(va)
      assert_error(Valpa.maybe_uniq_list([1, 1, 2]), error(:maybe_uniq_list, [1, 1, 2], nil))
    end

    test "map/1" do
      va = %{a: 1}
      assert Valpa.maybe_map(va) == ok(va)
      va = nil
      assert Valpa.maybe_map(va) == ok(va)
      assert_error(Valpa.maybe_map([1, 1, 2]), error(:maybe_map, [1, 1, 2], nil))
    end

    test "nonempty_map/1" do
      va = %{a: 1}
      assert Valpa.maybe_nonempty_map(va) == ok(va)
      va = nil
      assert Valpa.maybe_nonempty_map(va) == ok(va)
      assert_error(Valpa.maybe_nonempty_map(%{}), error(:maybe_nonempty_map, %{}, nil))
    end
  end

  describe "list validations" do
    test "list_of_type/2" do
      va = [1, 2, 3]
      assert Valpa.maybe_list_of_type(va, :integer) == ok(va)
      va = nil
      assert Valpa.maybe_list_of_type(va, :integer) == ok(va)

      assert_error(
        Valpa.maybe_list_of_type([1, "2", 3], :integer),
        error(:maybe_list_of_type, [1, "2", 3], :integer)
      )
    end

    test "list_of_values/2" do
      va = [:a, :b]
      assert Valpa.maybe_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.maybe_list_of_values([:a, :d], [:a, :b, :c]),
        error(:maybe_list_of_values, [:a, :d], [:a, :b, :c])
      )
    end

    test "uniq_list_of_type/2" do
      va = [1, 2, 3]
      assert Valpa.maybe_uniq_list_of_type(va, :integer) == ok(va)
      va = nil
      assert Valpa.maybe_uniq_list_of_type(va, :integer) == ok(va)

      assert_error(
        Valpa.maybe_uniq_list_of_type([1, 1, 2], :integer),
        error(:maybe_uniq_list_of_type, [1, 1, 2], :integer)
      )
    end

    test "uniq_list_of_values/2" do
      va = [:a, :b]
      assert Valpa.maybe_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.maybe_uniq_list_of_values([:a, :a], [:a, :b, :c]),
        error(:maybe_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end
  end

  describe "value validations" do
    test "value_of_values/2" do
      va = :a
      assert Valpa.maybe_value_of_values(va, [:a, :b, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_value_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.maybe_value_of_values(:d, [:a, :b, :c]),
        error(:maybe_value_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_list_of_values/2" do
      va = :a
      assert Valpa.maybe_value_or_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = [:a, :b]
      assert Valpa.maybe_value_or_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_value_or_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.maybe_value_or_list_of_values(:d, [:a, :b, :c]),
        error(:maybe_value_or_list_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_uniq_list_of_values/2" do
      va = :a
      assert Valpa.maybe_value_or_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = [:a, :b]
      assert Valpa.maybe_value_or_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_value_or_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.maybe_value_or_uniq_list_of_values([:a, :a], [:a, :b, :c]),
        error(:maybe_value_or_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end

    test "maybe_integer_in_range/2" do
      va = 40
      assert Valpa.maybe_integer_in_range(va, %{min: 10, max: 50}) == ok(va)
      va = nil
      assert Valpa.maybe_integer_in_range(va, %{min: 10, max: 50}) == ok(va)

      assert_error(
        Valpa.maybe_integer_in_range(60, %{min: 10, max: 50}),
        error(:maybe_integer_in_range, 60, %{min: 10, max: 50})
      )
    end

    test "maybe_map_inclusive_keys/2" do
      va = %{a: 1, b: 2}
      assert Valpa.maybe_map_inclusive_keys(va, [:a, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_map_inclusive_keys(va, [:a, :c]) == ok(va)

      assert_error(
        Valpa.maybe_map_inclusive_keys(%{b: 2}, [:a, :c]),
        error(:maybe_map_inclusive_keys, %{b: 2}, [:a, :c])
      )
    end

    test "maybe_map_exclusive_keys/2" do
      va = %{a: 1, b: 2}
      assert Valpa.maybe_map_exclusive_keys(va, [:a, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_map_exclusive_keys(va, [:a, :c]) == ok(va)

      assert_error(
        Valpa.maybe_map_exclusive_keys(%{a: 1, c: 2}, [:a, :c]),
        error(:maybe_map_exclusive_keys, %{a: 1, c: 2}, [:a, :c])
      )
    end

    test "maybe_map_exclusive_optional_keys/2" do
      va = %{a: 1}
      assert Valpa.maybe_map_exclusive_optional_keys(va, [:a, :c]) == ok(va)
      va = nil
      assert Valpa.maybe_map_exclusive_optional_keys(va, [:a, :c]) == ok(va)
      assert Valpa.maybe_map_exclusive_optional_keys(%{}, [:a, :c]) == ok(%{})
      assert Valpa.maybe_map_exclusive_optional_keys(%{a: nil}, [:a, :c]) == ok(%{a: nil})

      assert_error(
        Valpa.maybe_map_exclusive_optional_keys(%{a: 1, c: 2}, [:a, :c]),
        error(:maybe_map_exclusive_optional_keys, %{a: 1, c: 2}, [:a, :c])
      )
    end
  end

  test "decimal/1" do
    va = Decimal.new("3.14")
    assert Valpa.maybe_decimal(va) == ok(va)
    va = nil
    assert Valpa.maybe_decimal(va) == ok(va)

    assert_error(Valpa.maybe_decimal(3.14), error(:maybe_decimal, 3.14))
  end
end
