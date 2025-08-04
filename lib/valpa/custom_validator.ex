defmodule Valpa.CustomValidator do
  @moduledoc """
  Behaviour for custom validators.

  Implement the `validate/1` callback to return:

  * `:ok` — if the value is valid
  * `{:error, %Valpa.Error{}}` — if the value is invalid

  Example:

  ```
  defmodule MyApp.Validators.PositiveInteger do
    @behaviour Valpa.CustomValidator

    @impl true
    def validate(val) when is_integer(val) and val > 0, do: :ok
    def validate(val), do:
      {:error, Valpa.Error.new(%{
        validator: :positive_integer,
        value: val,
        criteria: "> 0"
      })}
  end
  ```
  """

  @callback validate(term) :: :ok | {:error, Valpa.Error.t()}
  @type validate :: (term -> :ok | {:error, Valpa.Error.t()})
  @type t :: module()

  def ensure_behaviour(validator) do
    exports = validator.module_info(:exports)

    validate_exported =
      Enum.any?(exports, fn {name, arity} -> name == :validate and arity == 1 end)

    unless validate_exported do
      raise ArgumentError,
            "Validator module #{inspect(validator)} does not implement Valpa.CustomValidator behaviour"
    end
  end
end
