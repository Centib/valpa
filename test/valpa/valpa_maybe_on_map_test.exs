defmodule Valpa.ValpaMaybeOnMapTest do
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
      assert map |> Valpa.maybe_integer(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_integer(:key) == ok(map)
      assert_error(%{key: "42"} |> Valpa.maybe_integer(:key), error(:maybe_integer, "42"))
    end

    test "float/1" do
      map = %{key: 3.14}
      assert map |> Valpa.maybe_float(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_float(:key) == ok(map)
      assert_error(%{key: 42} |> Valpa.maybe_float(:key), error(:maybe_float, 42))
    end

    test "string/1" do
      map = %{key: "hello"}
      assert map |> Valpa.maybe_string(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_string(:key) == ok(map)
      assert_error(%{key: 42} |> Valpa.maybe_string(:key), error(:maybe_string, 42))
    end

    test "boolean/1" do
      map = %{key: true}
      assert map |> Valpa.maybe_boolean(:key) == ok(map)
      map = %{key: false}
      assert map |> Valpa.maybe_boolean(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_boolean(:key) == ok(map)
      assert_error(%{key: 42} |> Valpa.maybe_boolean(:key), error(:maybe_boolean, 42))
    end

    test "list/1" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.maybe_list(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_list(:key) == ok(map)
      assert_error(%{key: 42} |> Valpa.maybe_list(:key), error(:maybe_list, 42))
    end

    test "uniq_list/1" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.maybe_uniq_list(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_uniq_list(:key) == ok(map)

      assert_error(
        %{key: [1, 1, 2]} |> Valpa.maybe_uniq_list(:key),
        error(:maybe_uniq_list, [1, 1, 2])
      )
    end

    test "map/1" do
      map = %{key: %{a: 1}}
      assert map |> Valpa.maybe_map(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_map(:key) == ok(map)

      assert_error(%{key: [1, 1, 2]} |> Valpa.maybe_map(:key), error(:maybe_map, [1, 1, 2]))
    end

    test "nonempty_map/1" do
      map = %{key: %{a: 1}}
      assert map |> Valpa.maybe_nonempty_map(:key) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_nonempty_map(:key) == ok(map)

      assert_error(
        %{key: %{}} |> Valpa.maybe_nonempty_map(:key),
        error(:maybe_nonempty_map, %{})
      )
    end
  end

  describe "list validations" do
    test "list_of_type/2" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.maybe_list_of_type(:key, :integer) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_list_of_type(:key, :integer) == ok(map)

      assert_error(
        %{key: [1, "2", 3]} |> Valpa.maybe_list_of_type(:key, :integer),
        error(:maybe_list_of_type, [1, "2", 3], :integer)
      )
    end

    test "list_of_values/2" do
      map = %{key: [:a, :b]}
      assert map |> Valpa.maybe_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :d]} |> Valpa.maybe_list_of_values(:key, [:a, :b, :c]),
        error(:maybe_list_of_values, [:a, :d], [:a, :b, :c])
      )
    end

    test "uniq_list_of_type/2" do
      map = %{key: [1, 2, 3]}
      assert map |> Valpa.maybe_uniq_list_of_type(:key, :integer) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_uniq_list_of_type(:key, :integer) == ok(map)

      assert_error(
        %{key: [1, 1, 2]} |> Valpa.maybe_uniq_list_of_type(:key, :integer),
        error(:maybe_uniq_list_of_type, [1, 1, 2], :integer)
      )
    end

    test "uniq_list_of_values/2" do
      map = %{key: [:a, :b]}
      assert map |> Valpa.maybe_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :a]} |> Valpa.maybe_uniq_list_of_values(:key, [:a, :b, :c]),
        error(:maybe_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end
  end

  describe "value validations" do
    test "value_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.maybe_value_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_value_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: :d} |> Valpa.maybe_value_of_values(:key, [:a, :b, :c]),
        error(:maybe_value_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_list_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.maybe_value_or_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: [:a, :b]}
      assert map |> Valpa.maybe_value_or_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_value_or_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: :d} |> Valpa.maybe_value_or_list_of_values(:key, [:a, :b, :c]),
        error(:maybe_value_or_list_of_values, :d, [:a, :b, :c])
      )
    end

    test "value_or_uniq_list_of_values/2" do
      map = %{key: :a}
      assert map |> Valpa.maybe_value_or_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: [:a, :b]}
      assert map |> Valpa.maybe_value_or_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_value_or_uniq_list_of_values(:key, [:a, :b, :c]) == ok(map)

      assert_error(
        %{key: [:a, :a]} |> Valpa.maybe_value_or_uniq_list_of_values(:key, [:a, :b, :c]),
        error(:maybe_value_or_uniq_list_of_values, [:a, :a], [:a, :b, :c])
      )
    end

    test "maybe_integer_in_range/2" do
      map = %{key: 40}
      assert map |> Valpa.maybe_integer_in_range(:key, %{min: 10, max: 50}) == ok(map)
      map = %{key: nil}
      assert map |> Valpa.maybe_integer_in_range(:key, %{min: 10, max: 50}) == ok(map)

      assert_error(
        %{key: 60} |> Valpa.maybe_integer_in_range(:key, %{min: 10, max: 50}),
        error(:maybe_integer_in_range, 60, %{min: 10, max: 50})
      )
    end
  end

  test "decimal/1" do
    map = %{key: Decimal.new("3.14")}
    assert map |> Valpa.maybe_decimal(:key) == ok(map)
    map = %{key: nil}
    assert map |> Valpa.maybe_decimal(:key) == ok(map)
    assert_error(%{key: 3.14} |> Valpa.maybe_decimal(:key), error(:maybe_decimal, 3.14))
  end
end
