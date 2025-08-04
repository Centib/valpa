defmodule Valpa.Custom do
  @moduledoc """
  “Custom” validators that wrap user-provided functions or modules
  implementing the `Valpa.CustomValidator` behaviour and always return

    * `{:ok, value}`
    * `{:ok, map}`
    * `{:error, reason}`

  instead of raising. All functions accept:

    * A raw `value`
    * An `{:ok, value}` tuple (it unwraps and re-validates)
    * An `{:error, reason}` tuple (it propagates unchanged)

  This makes them fully composable in `|>` pipelines.
  """

  alias Valpa.CustomValidator
  import Loe

  defp do_validate(value, validate) do
    case validate.(value) do
      :ok -> {:ok, value}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_maybe_validate(value, validate) do
    case value do
      nil -> {:ok, nil}
      _ -> do_validate(value, validate)
    end
  end

  defp do_map_validate(map, key, validate) do
    case validate.(Map.fetch!(map, key)) do
      :ok ->
        {:ok, map}

      {:error, %Valpa.Error{} = reason} ->
        {:error,
         if(reason.field == nil,
           do: Valpa.Error.at(reason, key),
           else: reason
         )}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_map_maybe_validate(map, key, validate) do
    case Map.fetch!(map, key) do
      nil -> {:ok, map}
      _ -> do_map_validate(map, key, validate)
    end
  end

  @doc """
  Apply a simple validation function to `input`.

  ## Parameters
    * `input` — raw term, `{:ok, term}`, or `{:error, reason}`
    * `validate` — a `(term -> :ok | {:error, reason})` function

  ## Returns
    * `{:ok, value}` if `validate.(value) == :ok`
    * `{:error, reason}` if `validate.(value) == {:error, reason}`
    * Propagates existing `{:error, reason}` unchanged
  """
  @spec validate(
          term | {:ok, term} | {:error, any},
          CustomValidator.validate()
        ) :: {:ok, term} | {:error, any}
  def validate(input, validate) when is_function(validate, 1) do
    input ~>> do_validate(validate)
  end

  @doc """
  Like `validate/2` but treats `nil` as valid and returns `{:ok, nil}`.
  """
  @spec maybe_validate(
          term | {:ok, term} | {:error, any},
          CustomValidator.validate()
        ) :: {:ok, term | nil} | {:error, any}
  def maybe_validate(input, validate) when is_function(validate, 1) do
    input ~>> do_maybe_validate(validate)
  end

  @doc """
  Delegate to a `Valpa.CustomValidator` module.

  ## Parameters
    * `input` — raw term, `{:ok, term}`, or `{:error, reason}`
    * `validator` — a module implementing `Valpa.CustomValidator`

  ## Returns
    * `{:ok, value}` on success
    * `{:error, reason}` on failure
    * Propagates existing `{:error, reason}` unchanged
  """
  @spec validator(
          term | {:ok, term} | {:error, any},
          CustomValidator.t()
        ) :: {:ok, term} | {:error, any}
  def validator(input, validator) do
    CustomValidator.ensure_behaviour(validator)
    input ~>> do_validate(&validator.validate/1)
  end

  @doc """
  Like `validator/2` but returns `{:ok, nil}` if the input is `nil`.
  """
  @spec maybe_validator(
          term | {:ok, term} | {:error, any},
          CustomValidator.t()
        ) :: {:ok, term | nil} | {:error, any}
  def maybe_validator(input, validator) do
    CustomValidator.ensure_behaviour(validator)
    input ~>> do_maybe_validate(&validator.validate/1)
  end

  @doc """
  Run a `Valpa.CustomValidator` against a single map field.

  ## Returns
    * `{:ok, map}` if the field passes validation
    * `{:error, reason}` on failure
    * Propagates existing `{:error, reason}` unchanged
  """
  @spec validator(
          map() | {:ok, map()} | {:error, any},
          atom,
          CustomValidator.t()
        ) :: {:ok, map()} | {:error, any}
  def validator(input, key, validator) do
    CustomValidator.ensure_behaviour(validator)
    input ~>> do_map_validate(key, &validator.validate/1)
  end

  @doc """
  Like `validator/3` but returns {:ok, map} if `Map.fetch!(map, key)` is `nil`.
  """
  @spec maybe_validator(
          map() | {:ok, map()} | {:error, any},
          atom,
          CustomValidator.t()
        ) :: {:ok, map()} | {:error, any}
  def maybe_validator(input, key, validator) do
    CustomValidator.ensure_behaviour(validator)
    input ~>> do_map_maybe_validate(key, &validator.validate/1)
  end
end
