defmodule Valpa.ValpaTest do
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
      assert Valpa.integer(va) == ok(va)
      assert_error(Valpa.integer("42"), error(:integer, "42"))
    end

    test "float/1" do
      va = 3.14
      assert Valpa.float(va) == ok(va)
      assert_error(Valpa.float(42), error(:float, 42))
    end

    test "string/1" do
      va = "hello"
      assert Valpa.string(va) == ok(va)
      assert_error(Valpa.string(123), error(:string, 123))
    end

    test "boolean/1" do
      va = true
      assert Valpa.boolean(va) == ok(va)
      va = false
      assert Valpa.boolean(va) == ok(va)
      assert_error(Valpa.boolean(1), error(:boolean, 1))
    end

    test "list/1" do
      va = [1, 2, 3]
      assert Valpa.list(va) == ok(va)
      assert_error(Valpa.list(123), error(:list, 123))
    end

    test "uniq_list/1" do
      va = [1, 2, 3]
      assert Valpa.uniq_list(va) == ok(va)
      assert_error(Valpa.uniq_list([1, 1, 2]), error(:uniq_list, [1, 1, 2]))
    end

    test "map/1" do
      va = %{a: 1}
      assert Valpa.map(va) == ok(va)
      assert_error(Valpa.map([1, 1, 2]), error(:map, [1, 1, 2]))
    end

    test "nonempty_map/1" do
      va = %{a: 1}
      assert Valpa.nonempty_map(va) == ok(va)
      assert_error(Valpa.nonempty_map(%{}), error(:nonempty_map, %{}))
    end
  end

  describe "list validations" do
    test "list_of_type/2" do
      va = [1, 2, 3]
      assert Valpa.list_of_type(va, :integer) == ok(va)

      assert_error(
        Valpa.list_of_type([1, "2", 3], :integer),
        error(:list_of_type, [1, "2", 3], :integer)
      )
    end

    test "list_of_values/2" do
      va = [:a, :b]
      assert Valpa.list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.list_of_values([:a, :d], [:a, :b, :c]),
        error(:list_of_values, [:a, :d], [:a, :b, :c])
      )
    end

    test "uniq_list_of_type/2" do
      va = [1, 2, 3]
      assert Valpa.uniq_list_of_type(va, :integer) == ok(va)

      assert_error(
        Valpa.uniq_list_of_type([1, 1, 2], :integer),
        error(:uniq_list_of_type, [1, 1, 2], :integer)
      )
    end

    test "uniq_list_of_values/2" do
      va = [:a, :b]
      assert Valpa.uniq_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.uniq_list_of_values([:a, :a], [:a, :b, :c]),
        error(:uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end
  end

  describe "value validations" do
    test "value_of_values/2" do
      va = :a
      assert Valpa.value_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.value_of_values(:d, [:a, :b, :c]),
        error(:value_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_list_of_values/2" do
      va = :a
      assert Valpa.value_or_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = [:a, :b]
      assert Valpa.value_or_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.value_or_list_of_values(:d, [:a, :b, :c]),
        error(:value_or_list_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_uniq_list_of_values/2" do
      va = :a
      assert Valpa.value_or_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)
      va = [:a, :b]
      assert Valpa.value_or_uniq_list_of_values(va, [:a, :b, :c]) == ok(va)

      assert_error(
        Valpa.value_or_uniq_list_of_values([:a, :a], [:a, :b, :c]),
        error(:value_or_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end

    test "integer_in_range/2" do
      va = 40
      assert Valpa.integer_in_range(va, %{min: 10, max: 50}) == ok(va)

      assert_error(
        Valpa.integer_in_range(60, %{min: 10, max: 50}),
        error(:integer_in_range, 60, %{min: 10, max: 50})
      )
    end

    test "map_inclusive_keys/2" do
      va = %{a: 1, b: 2}
      assert Valpa.map_inclusive_keys(va, [:a, :c]) == ok(va)

      assert_error(
        Valpa.map_inclusive_keys(%{b: 2}, [:a, :c]),
        error(:map_inclusive_keys, %{b: 2}, [:a, :c])
      )
    end

    test "map_exclusive_keys/2" do
      va = %{a: 1, b: 2}
      assert Valpa.map_exclusive_keys(va, [:a, :c]) == ok(va)

      assert_error(
        Valpa.map_exclusive_keys(%{a: 1, c: 2}, [:a, :c]),
        error(:map_exclusive_keys, %{a: 1, c: 2}, [:a, :c])
      )
    end

    test "map_exclusive_optional_keys/2" do
      va = %{a: 1}
      assert Valpa.map_exclusive_optional_keys(va, [:a, :c]) == ok(va)

      assert Valpa.map_exclusive_optional_keys(%{}, [:a, :c]) == ok(%{})

      assert Valpa.map_exclusive_optional_keys(%{a: nil}, [:a, :c]) == ok(%{a: nil})

      assert_error(
        Valpa.map_exclusive_optional_keys(%{a: 1, c: 2}, [:a, :c]),
        error(:map_exclusive_optional_keys, %{a: 1, c: 2}, [:a, :c])
      )
    end
  end

  describe "decimal validations" do
    test "decimal/1" do
      va = Decimal.new("3.14")
      assert Valpa.decimal(va) == ok(va)
      assert_error(Valpa.decimal(3.14), error(:decimal, 3.14))
    end

    test "decimal_in_range_inclusive/2" do
      assert Valpa.decimal_in_range_inclusive(Decimal.new("5"), %{
               min: Decimal.new("5"),
               max: Decimal.new("10")
             }) ==
               ok(Decimal.new("5"))

      assert Valpa.decimal_in_range_inclusive(Decimal.new("10"), %{
               min: Decimal.new("5"),
               max: Decimal.new("10")
             }) == ok(Decimal.new("10"))

      assert Valpa.decimal_in_range_inclusive(Decimal.new("7.5"), %{
               min: Decimal.new("5"),
               max: Decimal.new("10")
             }) == ok(Decimal.new("7.5"))

      assert_error(
        Valpa.decimal_in_range_inclusive(Decimal.new("4.9"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_inclusive, Decimal.new("4.9"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )

      assert_error(
        Valpa.decimal_in_range_inclusive(Decimal.new("10.1"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_inclusive, Decimal.new("10.1"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )
    end

    test "decimal_in_range_exclusive/2" do
      assert Valpa.decimal_in_range_exclusive(Decimal.new("7.5"), %{
               min: Decimal.new("5"),
               max: Decimal.new("10")
             }) == ok(Decimal.new("7.5"))

      assert_error(
        Valpa.decimal_in_range_exclusive(Decimal.new("5"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_exclusive, Decimal.new("5"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )

      assert_error(
        Valpa.decimal_in_range_exclusive(Decimal.new("10"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_exclusive, Decimal.new("10"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )

      assert_error(
        Valpa.decimal_in_range_exclusive(Decimal.new("4.9"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_exclusive, Decimal.new("4.9"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )

      assert_error(
        Valpa.decimal_in_range_exclusive(Decimal.new("10.1"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        }),
        error(:decimal_in_range_exclusive, Decimal.new("10.1"), %{
          min: Decimal.new("5"),
          max: Decimal.new("10")
        })
      )
    end
  end
end
