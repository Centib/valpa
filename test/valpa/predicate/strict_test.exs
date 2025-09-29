defmodule Valpa.Predicate.StrictTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias Valpa.Predicate.Validator

  # Test integer/1
  test "integer returns true for integers" do
    assert Validator.integer(42)
  end

  test "integer returns false for non-integers" do
    refute Validator.integer("42")
    refute Validator.integer(42.0)
  end

  # Test float/1
  test "float returns true for floats" do
    assert Validator.float(42.0)
  end

  test "float returns false for non-floats" do
    refute Validator.float(42)
    refute Validator.float("42.0")
  end

  # Test binary/1
  test "binary returns true for binaries" do
    assert Validator.string("hello")
  end

  test "binary returns false for non-binaries" do
    refute Validator.string(42)
    refute Validator.string([1, 2, 3])
  end

  # Test boolean/1
  test "boolean returns true for booleans" do
    assert Validator.boolean(true)
    assert Validator.boolean(false)
  end

  test "boolean returns false for non-booleans" do
    refute Validator.boolean(42)
    refute Validator.boolean("true")
  end

  # Test list/1
  test "list returns true for lists" do
    assert Validator.list([1, 2, 3])
  end

  test "list returns false for non-lists" do
    refute Validator.list(42)
    refute Validator.list("hello")
  end

  # Test uniq_list/1
  test "uniq_list returns true for unique lists" do
    assert Validator.uniq_list([1, 2, 3])
  end

  test "uniq_list returns false for non-unique lists" do
    refute Validator.uniq_list([1, 2, 2, 3])
  end

  # Test map/1
  test "map returns true for map" do
    assert Validator.map(%{a: 1})
  end

  test "map returns false for non-map" do
    refute Validator.map([1, 2, 2, 3])
    refute Validator.map("non-map")
  end

  # Test nonempty_map/1
  test "nonempty_map returns true for non-empty map" do
    assert Validator.nonempty_map(%{a: 1})
  end

  test "nonempty_map returns false for empty map or no map at all" do
    refute Validator.nonempty_map(%{})
    refute Validator.nonempty_map([1, 2, 3])
  end

  # Test list_of_type/2
  test "list_of_type returns true for lists with matching types" do
    assert Validator.list_of_type([1, 2, 3], :integer)
  end

  test "list_of_type returns false for lists with non-matching types" do
    refute Validator.list_of_type([1, 2, "3"], :integer)
  end

  # Test list_of_values/2
  test "list_of_values returns true for lists containing valid values" do
    assert Validator.list_of_values([1, 2, 3], [1, 2, 3, 4])
  end

  test "list_of_values returns false for lists containing invalid values" do
    refute Validator.list_of_values([1, 2, 5], [1, 2, 3, 4])
  end

  # Test uniq_list_of_type/2
  test "uniq_list_of_type returns true for unique lists with matching types" do
    assert Validator.uniq_list_of_type([1, 2, 3], :integer)
  end

  test "uniq_list_of_type returns false for non-unique lists or lists with non-matching types" do
    refute Validator.uniq_list_of_type([1, 2, 2, 3], :integer)
    refute Validator.uniq_list_of_type([1, 2, "3"], :integer)
  end

  # Test uniq_list_of_values/2
  test "uniq_list_of_values returns true for unique lists with valid values" do
    assert Validator.uniq_list_of_values([1, 2, 3], [1, 2, 3, 4])
  end

  test "uniq_list_of_values returns false for non-unique lists or lists with invalid values" do
    refute Validator.uniq_list_of_values([1, 2, 2, 3], [1, 2, 3, 4])
    refute Validator.uniq_list_of_values([1, 2, 5], [1, 2, 3, 4])
  end

  # Test value_of_values/2
  test "value_of_values returns true for valid values" do
    assert Validator.value_of_values(3, [1, 2, 3])
  end

  test "value_of_values returns false for invalid values" do
    refute Validator.value_of_values(5, [1, 2, 3])
  end

  # Test value_or_list_of_values/2
  test "value_or_list_of_values returns true for valid values or valid list of values" do
    assert Validator.value_or_list_of_values(3, [1, 2, 3])
    assert Validator.value_or_list_of_values([1, 2], [1, 2, 3])
  end

  test "value_or_list_of_values returns false for invalid values and invalid list of values" do
    refute Validator.value_or_list_of_values(5, [1, 2, 3])
    refute Validator.value_or_list_of_values([1, 4], [1, 2, 3])
  end

  # Test value_or_uniq_list_of_values/2
  test "value_or_uniq_list_of_values returns true for valid values or valid unique list of values" do
    assert Validator.value_or_uniq_list_of_values(3, [1, 2, 3])
    assert Validator.value_or_uniq_list_of_values([1, 2], [1, 2, 3])
  end

  test "value_or_uniq_list_of_values returns false for invalid values and invalid unique list of values" do
    refute Validator.value_or_uniq_list_of_values(5, [1, 2, 3])
    refute Validator.value_or_uniq_list_of_values([1, 4], [1, 2, 3])
    refute Validator.value_or_uniq_list_of_values([1, 2, 2], [1, 2, 3])
  end

  # Test map_inclusive_keys/2
  test "map_inclusive_keys returns true if one or more non-nil-value-keys exists" do
    assert Validator.map_inclusive_keys(%{a: 1, b: 2}, [:a, :c])
    assert Validator.map_inclusive_keys(%{a: 1, c: 2}, [:a, :c])
  end

  test "map_inclusive_keys returns false if non of non-nil-value-keys exists" do
    refute Validator.map_inclusive_keys(%{b: 2}, [:a, :c])
    refute Validator.map_inclusive_keys(%{a: nil, c: nil}, [:a, :c])
  end

  # Test map_inclusive_keys/2
  test "map_exclusive_keys returns true if one non-nil-value-key exists" do
    assert Validator.map_exclusive_keys(%{a: 1, b: 2}, [:a, :c])
    assert Validator.map_exclusive_keys(%{b: 1, c: 2}, [:a, :c])
    assert Validator.map_exclusive_keys(%{a: nil, c: 2}, [:a, :c])
  end

  test "map_exclusive_keys returns false if both non-nil-value-keys exists or non of non-nil-value-keys exists" do
    refute Validator.map_exclusive_keys(%{a: 1, c: 2}, [:a, :c])
    refute Validator.map_exclusive_keys(%{a: nil, c: nil}, [:a, :c])
    refute Validator.map_exclusive_keys(%{}, [:a, :c])
  end

  # Test map_exclusive_optional_keys/2
  test "map_exclusive_optional_keys returns true if zero or one of non-nil-value-keys exist" do
    assert Validator.map_exclusive_optional_keys(%{x: 1}, [:a, :b])
    assert Validator.map_exclusive_optional_keys(%{a: 1}, [:a, :b])
    assert Validator.map_exclusive_optional_keys(%{}, [:a, :b])
    assert Validator.map_exclusive_optional_keys(%{a: nil, c: nil}, [:a, :b])
  end

  test "map_exclusive_optional_keys returns false if more than one of non-nil-value-keys exist" do
    refute Validator.map_exclusive_optional_keys(%{a: 1, b: 2}, [:a, :b])
    refute Validator.map_exclusive_optional_keys(%{a: 1, b: 2, x: 3}, [:a, :b])
  end

  # Test decimal/1
  test "decimal returns true for decimals" do
    assert Validator.decimal(Decimal.new("42.0"))
  end

  test "decimal returns false for non-decimals" do
    refute Validator.decimal(42.0)
    refute Validator.decimal("42.0")
  end

  # Test decimal_in_range_inclusive/2
  test "decimal_in_range_inclusive returns true when value is within or equal to bounds" do
    assert Validator.decimal_in_range_inclusive(Decimal.new("5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.decimal_in_range_inclusive(Decimal.new("10"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    assert Validator.decimal_in_range_inclusive(Decimal.new("7.5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  test "decimal_in_range_inclusive returns false when value is outside bounds" do
    refute Validator.decimal_in_range_inclusive(Decimal.new("4.9"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.decimal_in_range_inclusive(Decimal.new("10.1"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  # Test decimal_in_range_exclusive/2
  test "decimal_in_range_exclusive returns true when value is strictly within bounds" do
    assert Validator.decimal_in_range_exclusive(Decimal.new("7.5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end

  test "decimal_in_range_exclusive returns false when value equals bounds" do
    refute Validator.decimal_in_range_exclusive(Decimal.new("5"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })

    refute Validator.decimal_in_range_exclusive(Decimal.new("10"), %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           })
  end
end
