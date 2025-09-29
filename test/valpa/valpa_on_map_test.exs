defmodule Valpa.ValpaOnMapTest do
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
       field: :key,
       criteria: criteria
     })}
  end

  def assert_error({:error, left}, {:error, right}) do
    assert Map.delete(left, :__trace__) == Map.delete(right, :__trace__)
  end

  describe "type validations" do
    test "integer/1" do
      map = %{key: 42}
      assert map |> Valpa.integer(:key) == ok(map)
      assert_error(%{key: "42"} |> Valpa.integer(:key), error(:integer, "42"))
    end

    test "float/1" do
      map = %{key: 3.14}
      assert map |> Valpa.float(:key) == ok(map)
      assert_error(%{key: 42} |> Valpa.float(:key), error(:float, 42))
    end

    test "string/1" do
      map = %{key: "hello"}
      assert map |> Valpa.string(:key) == ok(map)
      assert_error(%{key: 123} |> Valpa.string(:key), error(:string, 123))
    end

    test "boolean/1" do
      map = %{key: true}
      assert map |> Valpa.boolean(:key) == ok(map)
      map = %{key: false}
      assert map |> Valpa.boolean(:key) == ok(map)
      assert_error(%{key: 1} |> Valpa.boolean(:key), error(:boolean, 1))
    end

    test "list/1" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.list(:key) == ok(map)
      assert_error(%{key: 123} |> Valpa.list(:key), error(:list, 123))
    end

    test "uniq_list/1" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.uniq_list(:key) == ok(map)
      assert_error(%{key: [1, 1, 2]} |> Valpa.uniq_list(:key), error(:uniq_list, [1, 1, 2]))
    end

    test "map/1" do
      map = %{key: %{a: 1}}
      assert map |> Valpa.map(:key) == ok(map)
      assert_error(%{key: [1, 1, 2]} |> Valpa.map(:key), error(:map, [1, 1, 2]))
    end

    test "nonempty_map/1" do
      map = %{key: %{a: 1}}
      assert map |> Valpa.nonempty_map(:key) == ok(map)
      assert_error(%{key: %{}} |> Valpa.nonempty_map(:key), error(:nonempty_map, %{}))
    end
  end

  describe "list validations" do
    test "list_of_type/2" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.list_of_type(:key, :integer) == ok(map)

      assert_error(
        %{key: [1, "2", 3]} |> Valpa.list_of_type(:key, :integer),
        error(:list_of_type, [1, "2", 3], :integer)
      )
    end

    test "list_of_values/2" do
      map = %{key: [:a, :b]}
      assert map |> Valpa.list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :d]} |> Valpa.list_of_values(:key, [:a, :b, :c]),
        error(:list_of_values, [:a, :d], [:a, :b, :c])
      )
    end

    test "uniq_list_of_type/2" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.uniq_list_of_type(:key, :integer) == ok(map)

      assert_error(
        %{key: [1, 1, 2]} |> Valpa.uniq_list_of_type(:key, :integer),
        error(:uniq_list_of_type, [1, 1, 2], :integer)
      )
    end

    test "uniq_list_of_values/2" do
      map = %{key: [:a, :b]}
      assert map |> Valpa.uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :a]} |> Valpa.uniq_list_of_values(:key, [:a, :b, :c]),
        error(:uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end
  end

  describe "value validations" do
    test "value_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.value_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: :d} |> Valpa.value_of_values(:key, [:a, :b, :c]),
        error(:value_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_list_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.value_or_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: [:a, :b]}
      assert map |> Valpa.value_or_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: :d} |> Valpa.value_or_list_of_values(:key, [:a, :b, :c]),
        error(:value_or_list_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_uniq_list_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.value_or_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: [:a, :b]}
      assert map |> Valpa.value_or_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :a]} |> Valpa.value_or_uniq_list_of_values(:key, [:a, :b, :c]),
        error(:value_or_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end

    test "integer_in_range/2" do
      map = %{key: 40}
      assert map |> Valpa.integer_in_range(:key, %{min: 10, max: 50}) == ok(map)

      assert_error(
        %{key: 60} |> Valpa.integer_in_range(:key, %{min: 10, max: 50}),
        error(:integer_in_range, 60, %{min: 10, max: 50})
      )
    end
  end

  test "decimal/1" do
    map = %{key: Decimal.new("3.14")}
    assert map |> Valpa.decimal(:key) == ok(map)
    assert_error(%{key: 3.14} |> Valpa.decimal(:key), error(:decimal, 3.14))
  end

  test "decimal_in_range_inclusive/2" do
    map = %{key: Decimal.new("5")}

    assert map
           |> Valpa.decimal_in_range_inclusive(:key, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           }) == ok(map)

    map = %{key: Decimal.new("10")}

    assert map
           |> Valpa.decimal_in_range_inclusive(:key, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           }) == ok(map)

    map = %{key: Decimal.new("7.5")}

    assert map
           |> Valpa.decimal_in_range_inclusive(:key, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           }) == ok(map)

    assert_error(
      %{key: Decimal.new("4.9")}
      |> Valpa.decimal_in_range_inclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_inclusive, Decimal.new("4.9"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )

    assert_error(
      %{key: Decimal.new("10.1")}
      |> Valpa.decimal_in_range_inclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_inclusive, Decimal.new("10.1"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )
  end

  test "decimal_in_range_exclusive/2" do
    map = %{key: Decimal.new("7.5")}

    assert map
           |> Valpa.decimal_in_range_exclusive(:key, %{
             min: Decimal.new("5"),
             max: Decimal.new("10")
           }) == ok(map)

    assert_error(
      %{key: Decimal.new("5")}
      |> Valpa.decimal_in_range_exclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_exclusive, Decimal.new("5"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )

    assert_error(
      %{key: Decimal.new("10")}
      |> Valpa.decimal_in_range_exclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_exclusive, Decimal.new("10"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )

    assert_error(
      %{key: Decimal.new("4.9")}
      |> Valpa.decimal_in_range_exclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_exclusive, Decimal.new("4.9"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )

    assert_error(
      %{key: Decimal.new("10.1")}
      |> Valpa.decimal_in_range_exclusive(:key, %{min: Decimal.new("5"), max: Decimal.new("10")}),
      error(:decimal_in_range_exclusive, Decimal.new("10.1"), %{
        min: Decimal.new("5"),
        max: Decimal.new("10")
      })
    )
  end
end
