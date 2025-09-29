defmodule Valpa.Predicate.MaybeTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Valpa.Predicate.Validator

  # Test integer/1
  test "integer returns true for integers" do
    assert Validator.maybe_integer(nil)
    assert Validator.maybe_integer(42)
  end

  test "integer returns false for non-integers" do
    refute Validator.maybe_integer("42")
    refute Validator.maybe_integer(42.0)
  end

  # Test float/1
  test "float returns true for floats" do
    assert Validator.maybe_float(nil)
    assert Validator.maybe_float(42.0)
  end

  test "float returns false for non-floats" do
    refute Validator.maybe_float(42)
    refute Validator.maybe_float("42.0")
  end

  # Test binary/1
  test "binary returns true for binaries" do
    assert Validator.maybe_string(nil)
    assert Validator.maybe_string("hello")
  end

  test "binary returns false for non-binaries" do
    refute Validator.maybe_string(42)
    refute Validator.maybe_string([1, 2, 3])
  end

  # Test boolean/1
  test "boolean returns true for booleans" do
    assert Validator.maybe_boolean(nil)
    assert Validator.maybe_boolean(true)
    assert Validator.maybe_boolean(false)
  end

  test "boolean returns false for non-booleans" do
    refute Validator.maybe_boolean(42)
    refute Validator.maybe_boolean("true")
  end

  # Test list/1
  test "list returns true for lists" do
    assert Validator.maybe_list(nil)
    assert Validator.maybe_list([1, 2, 3])
  end

  test "list returns false for non-lists" do
    refute Validator.maybe_list(42)
    refute Validator.maybe_list("hello")
  end

  # Test uniq_list/1
  test "uniq_list returns true for unique lists" do
    assert Validator.maybe_uniq_list(nil)
    assert Validator.maybe_uniq_list([1, 2, 3])
  end

  test "uniq_list returns false for non-unique lists" do
    refute Validator.maybe_uniq_list([1, 2, 2, 3])
  end

  # Test map/1
  test "map returns true for map" do
    assert Validator.maybe_map(nil)
    assert Validator.maybe_map(%{a: 1})
  end

  test "map returns false for non-map" do
    refute Validator.maybe_map([1, 2, 2, 3])
    refute Validator.maybe_map("non-map")
  end

  # Test nonempty_map/1
  test "nonempty_map returns true for non-empty map" do
    assert Validator.maybe_nonempty_map(nil)
    assert Validator.maybe_nonempty_map(%{a: 1})
  end

  test "nonempty_map returns false for empty map or no map at all" do
    refute Validator.maybe_nonempty_map(%{})
    refute Validator.maybe_nonempty_map([1, 2, 3])
  end

  # Test list_of_type/2
  test "list_of_type returns true for lists with matching types" do
    assert Validator.maybe_list_of_type(nil, :integer)
    assert Validator.maybe_list_of_type([1, 2, 3], :integer)
  end

  test "list_of_type returns false for lists with non-matching types" do
    refute Validator.maybe_list_of_type([1, 2, "3"], :integer)
  end

  # Test list_of_values/2
  test "list_of_values returns true for lists containing valid values" do
    assert Validator.maybe_list_of_values(nil, [1, 2, 3, 4])
    assert Validator.maybe_list_of_values([1, 2, 3], [1, 2, 3, 4])
  end

  test "list_of_values returns false for lists containing invalid values" do
    refute Validator.maybe_list_of_values([1, 2, 5], [1, 2, 3, 4])
  end

  # Test uniq_list_of_type/2
  test "uniq_list_of_type returns true for unique lists with matching types" do
    assert Validator.maybe_uniq_list_of_type(nil, :integer)
    assert Validator.maybe_uniq_list_of_type([1, 2, 3], :integer)
  end

  test "uniq_list_of_type returns false for non-unique lists or lists with non-matching types" do
    refute Validator.maybe_uniq_list_of_type([1, 2, 2, 3], :integer)
    refute Validator.maybe_uniq_list_of_type([1, 2, "3"], :integer)
  end

  # Test uniq_list_of_values/2
  test "uniq_list_of_values returns true for unique lists with valid values" do
    assert Validator.maybe_uniq_list_of_values(nil, [1, 2, 3, 4])
    assert Validator.maybe_uniq_list_of_values([1, 2, 3], [1, 2, 3, 4])
  end

  test "uniq_list_of_values returns false for non-unique lists or lists with invalid values" do
    refute Validator.maybe_uniq_list_of_values([1, 2, 2, 3], [1, 2, 3, 4])
    refute Validator.maybe_uniq_list_of_values([1, 2, 5], [1, 2, 3, 4])
  end

  # Test value_of_values/2
  test "value_of_values returns true for valid values" do
    assert Validator.maybe_value_of_values(nil, [1, 2, 3])
    assert Validator.maybe_value_of_values(3, [1, 2, 3])
  end

  test "value_of_values returns false for invalid values" do
    refute Validator.maybe_value_of_values(5, [1, 2, 3])
  end

  # Test value_or_list_of_values/2
  test "value_or_list_of_values returns true for valid values or valid list of values" do
    assert Validator.maybe_value_or_list_of_values(nil, [1, 2, 3])
    assert Validator.maybe_value_or_list_of_values(3, [1, 2, 3])
    assert Validator.maybe_value_or_list_of_values([1, 2], [1, 2, 3])
  end

  test "value_or_list_of_values returns false for invalid values and invalid list of values" do
    refute Validator.maybe_value_or_list_of_values(5, [1, 2, 3])
    refute Validator.maybe_value_or_list_of_values([1, 4], [1, 2, 3])
  end

  # Test value_or_uniq_list_of_values/2
  test "value_or_uniq_list_of_values returns true for valid values or valid unique list of values" do
    assert Validator.maybe_value_or_uniq_list_of_values(nil, [1, 2, 3])
    assert Validator.maybe_value_or_uniq_list_of_values(3, [1, 2, 3])
    assert Validator.maybe_value_or_uniq_list_of_values([1, 2], [1, 2, 3])
  end

  test "value_or_uniq_list_of_values returns false for invalid values and invalid unique list of values" do
    refute Validator.maybe_value_or_uniq_list_of_values(5, [1, 2, 3])
    refute Validator.maybe_value_or_uniq_list_of_values([1, 4], [1, 2, 3])
    refute Validator.maybe_value_or_uniq_list_of_values([1, 2, 2], [1, 2, 3])
  end

  # Test maybe_map_inclusive_keys/2
  test "maybe_map_inclusive_keys returns true if one or more keys exists or value is nil" do
    assert Validator.maybe_map_inclusive_keys(nil, [:a, :c])
    assert Validator.maybe_map_inclusive_keys(%{a: 1, b: 2}, [:a, :c])
    assert Validator.maybe_map_inclusive_keys(%{a: 1, c: 2}, [:a, :c])
  end

  test "maybe_map_inclusive_keys returns false if non of the keys exists but value is not nil" do
    refute Validator.maybe_map_inclusive_keys(%{b: 2}, [:a, :c])
  end

  # Test map_inclusive_keys/2
  test "maybe_map_exclusive_keys returns true if one or more keys exists" do
    assert Validator.maybe_map_exclusive_keys(nil, [:a, :c])
    assert Validator.maybe_map_exclusive_keys(%{a: 1, b: 2}, [:a, :c])
    assert Validator.maybe_map_exclusive_keys(%{b: 1, c: 2}, [:a, :c])
  end

  test "maybe_map_exclusive_keys returns false if non of the keys exists" do
    refute Validator.maybe_map_exclusive_keys(%{a: 1, c: 2}, [:a, :c])
  end

  # Test maybe_map_exclusive_optional_keys/2
  test "maybe_map_exclusive_optional_keys returns true if value is nil or zero/one key exists" do
    assert Validator.maybe_map_exclusive_optional_keys(nil, [:a, :c])
    assert Validator.maybe_map_exclusive_optional_keys(%{}, [:a, :c])
    assert Validator.maybe_map_exclusive_optional_keys(%{a: 1}, [:a, :c])
    assert Validator.maybe_map_exclusive_optional_keys(%{c: 1}, [:a, :c])
    assert Validator.maybe_map_exclusive_optional_keys(%{a: nil, c: nil}, [:a, :c])
  end

  test "maybe_map_exclusive_optional_keys returns false if more than one key exists" do
    refute Validator.maybe_map_exclusive_optional_keys(%{a: 1, c: 2}, [:a, :c])
    refute Validator.maybe_map_exclusive_optional_keys(%{a: 1, c: 2, x: 5}, [:a, :c])
  end

  # Test decimal/1
  test "decimal returns true for decimals" do
    assert Validator.maybe_decimal(nil)
    assert Validator.maybe_decimal(Decimal.new("42.0"))
  end

  test "decimal returns false for non-decimals" do
    refute Validator.maybe_decimal(42.0)
    refute Validator.maybe_decimal("42.0")
  end

  # Test maybe_decimal_in_range_inclusive/2
  test "maybe_decimal_in_range_inclusive returns true when value is nil or within/equal to bounds" do
    assert Validator.maybe_decimal_in_range_inclusive(nil, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.maybe_decimal_in_range_inclusive(Decimal.new("5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.maybe_decimal_in_range_inclusive(Decimal.new("10"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.maybe_decimal_in_range_inclusive(Decimal.new("7.5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  test "maybe_decimal_in_range_inclusive returns false when value is outside bounds" do
    refute Validator.maybe_decimal_in_range_inclusive(Decimal.new("4.9"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.maybe_decimal_in_range_inclusive(Decimal.new("10.1"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  # Test maybe_decimal_in_range_exclusive/2
  test "maybe_decimal_in_range_exclusive returns true when value is nil or strictly within bounds" do
    assert Validator.maybe_decimal_in_range_exclusive(nil, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.maybe_decimal_in_range_exclusive(Decimal.new("7.5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  test "maybe_decimal_in_range_exclusive returns false when value equals bounds or outside bounds" do
    refute Validator.maybe_decimal_in_range_exclusive(Decimal.new("5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.maybe_decimal_in_range_exclusive(Decimal.new("10"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.maybe_decimal_in_range_exclusive(Decimal.new("4.9"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.maybe_decimal_in_range_exclusive(Decimal.new("10.1"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end
end
