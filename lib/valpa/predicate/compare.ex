defmodule Valpa.Predicate.Compare do
  @moduledoc false
  require Decimal

  @ops [:>, :<, :>=, :<=, :==, :!=]

  # Shared nil-tolerant logic
  defp compare_optional(map, k1, k2, op, fun) when op in @ops do
    case {Map.get(map, k1), Map.get(map, k2)} do
      {nil, _} -> true
      {_, nil} -> true
      {v1, v2} -> fun.(v1, v2, op)
    end
  end

  # Integer comparison
  def compare_int_keys(map, k1, k2, op) do
    compare_optional(map, k1, k2, op, fn v1, v2, op ->
      if is_integer(v1) and is_integer(v2),
        do: apply_op(v1, v2, op),
        else: false
    end)
  end

  # Float comparison
  def compare_float_keys(map, k1, k2, op) do
    compare_optional(map, k1, k2, op, fn v1, v2, op ->
      if is_float(v1) and is_float(v2),
        do: apply_op(v1, v2, op),
        else: false
    end)
  end

  # Decimal comparison
  def compare_decimal_keys(map, k1, k2, op) do
    compare_optional(map, k1, k2, op, fn v1, v2, op ->
      if Decimal.is_decimal(v1) and Decimal.is_decimal(v2),
        do: decimal_compare(v1, v2, op),
        else: false
    end)
  end

  defp apply_op(v1, v2, :>), do: v1 > v2
  defp apply_op(v1, v2, :<), do: v1 < v2
  defp apply_op(v1, v2, :>=), do: v1 >= v2
  defp apply_op(v1, v2, :<=), do: v1 <= v2
  defp apply_op(v1, v2, :==), do: v1 == v2
  defp apply_op(v1, v2, :!=), do: v1 != v2

  defp decimal_compare(v1, v2, :>), do: Decimal.compare(v1, v2) == :gt
  defp decimal_compare(v1, v2, :<), do: Decimal.compare(v1, v2) == :lt
  defp decimal_compare(v1, v2, :>=), do: Decimal.compare(v1, v2) in [:gt, :eq]
  defp decimal_compare(v1, v2, :<=), do: Decimal.compare(v1, v2) in [:lt, :eq]
  defp decimal_compare(v1, v2, :==), do: Decimal.compare(v1, v2) == :eq
  defp decimal_compare(v1, v2, :!=), do: Decimal.compare(v1, v2) != :eq
end
