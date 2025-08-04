defmodule Valpa.ValpaCustomTest do
  @moduledoc false
  use ExUnit.Case, async: true

  # A dummy module to satisfy Valpa.CustomValidator behaviour
  defmodule DummyValidator do
    @moduledoc false
    @behaviour Valpa.CustomValidator

    @impl true
    def validate(val) when is_integer(val) and val > 0, do: :ok
    def validate(_), do: {:error, :invalid}
  end

  def positive(n) when is_integer(n) and n >= 0, do: :ok
  def positive(_), do: {:error, :negative}

  describe "custom_function/2" do
    test "returns {:ok, val} on raw valid input" do
      assert Valpa.Custom.validate(5, &__MODULE__.positive/1) == {:ok, 5}
    end

    test "returns {:error, reason} on raw invalid input" do
      assert Valpa.Custom.validate(-1, &__MODULE__.positive/1) == {:error, :negative}
    end

    test "unwraps {:ok, val} tuple" do
      assert Valpa.Custom.validate({:ok, 7}, &__MODULE__.positive/1) == {:ok, 7}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.validate({:error, :oops}, &__MODULE__.positive/1) == {:error, :oops}
    end
  end

  describe "maybe_custom_function/2" do
    test "returns {:ok, nil} for raw nil" do
      assert Valpa.Custom.maybe_validate(nil, &__MODULE__.positive/1) == {:ok, nil}
    end

    test "delegates to custom_function for non-nil raw value" do
      assert Valpa.Custom.maybe_validate(3, &__MODULE__.positive/1) == {:ok, 3}
    end

    test "unwraps {:ok, val} tuple" do
      assert Valpa.Custom.maybe_validate({:ok, 4}, &__MODULE__.positive/1) == {:ok, 4}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.maybe_validate({:error, :fail}, &__MODULE__.positive/1) ==
               {:error, :fail}
    end
  end

  describe "custom/2 (module validator)" do
    test "returns {:ok, val} when module validates raw value" do
      assert Valpa.Custom.validator(10, DummyValidator) == {:ok, 10}
    end

    test "returns {:error, reason} when module rejects raw value" do
      assert Valpa.Custom.validator(-5, DummyValidator) == {:error, :invalid}
    end

    test "unwraps {:ok, val} tuple" do
      assert Valpa.Custom.validator({:ok, 8}, DummyValidator) == {:ok, 8}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.validator({:error, :bad}, DummyValidator) == {:error, :bad}
    end
  end

  describe "custom/3 (map field validator)" do
    setup do
      valid = %{age: 21, name: "Alice"}
      invalid = %{age: -1}
      {:ok, valid: valid, invalid: invalid}
    end

    test "returns {:ok, map} when field is valid", %{valid: map} do
      assert Valpa.Custom.validator(map, :age, DummyValidator) == {:ok, map}
    end

    test "returns {:error, reason} when field is invalid", %{invalid: map} do
      assert Valpa.Custom.validator(map, :age, DummyValidator) == {:error, :invalid}
    end

    test "unwraps {:ok, map} tuple" do
      wrapped = {:ok, %{age: 15}}
      assert Valpa.Custom.validator(wrapped, :age, DummyValidator) == {:ok, %{age: 15}}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.validator({:error, :nope}, :age, DummyValidator) == {:error, :nope}
    end
  end

  describe "maybe_custom/2" do
    test "returns {:ok, nil} for raw nil" do
      assert Valpa.Custom.maybe_validator(nil, DummyValidator) == {:ok, nil}
    end

    test "delegates to custom/2 for non-nil raw value" do
      assert Valpa.Custom.maybe_validator(5, DummyValidator) == {:ok, 5}
    end

    test "unwraps {:ok, val} tuple" do
      assert Valpa.Custom.maybe_validator({:ok, 6}, DummyValidator) == {:ok, 6}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.maybe_validator({:error, :fail}, DummyValidator) == {:error, :fail}
    end
  end

  describe "maybe_custom/3" do
    setup do
      valid = %{score: 100}
      invalid = %{score: -10}
      {:ok, valid: valid, invalid: invalid}
    end

    test "returns {:ok, map} when field is valid", %{valid: map} do
      assert Valpa.Custom.maybe_validator(map, :score, DummyValidator) == {:ok, map}
    end

    test "returns {:ok, map} for map[key] == nil", %{valid: map} do
      map2 = %{map | score: nil}
      assert Valpa.Custom.maybe_validator(map2, :score, DummyValidator) == {:ok, map2}
    end

    test "returns {:error, reason} when field is invalid", %{invalid: map} do
      assert Valpa.Custom.maybe_validator(map, :score, DummyValidator) == {:error, :invalid}
    end

    test "unwraps {:ok, map} tuple" do
      wrapped = {:ok, %{score: 50}}
      assert Valpa.Custom.maybe_validator(wrapped, :score, DummyValidator) == {:ok, %{score: 50}}
    end

    test "propagates existing {:error, reason} tuple unchanged" do
      assert Valpa.Custom.maybe_validator({:error, :oops}, :score, DummyValidator) ==
               {:error, :oops}
    end
  end

  describe "pipeline through map-key validators" do
    test "validates multiple map keys in sequence" do
      map = %{age: 30, score: 80}

      result =
        map
        |> Valpa.Custom.validator(:age, DummyValidator)
        |> Valpa.Custom.validator(:score, DummyValidator)

      assert result == {:ok, map}
    end
  end
end
