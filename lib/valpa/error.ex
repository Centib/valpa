defmodule Valpa.Error do
  @moduledoc """
  ### Error Handling

  Valpa returns detailed error structs on validation failure. All errors use the `Valpa.Error` struct, which contains rich metadata and stacktrace info for debugging and logging.

  #### `Valpa.Error` structure

  ```elixir
  %Valpa.Error{
    validator: :integer,       # The failed validator name (e.g., :min, :string, :custom_validator)
    value: 3.14,               # The value that failed
    field: :age,               # (optional) Field name
    criteria: nil,             # (optional) Validator-specific context (like min-max range for example)
    text: nil,                 # (optional) Custom error message
    __trace__: [...]           # Internal trace, used for error reporting
  }
  ```

  #### Constructing Errors

  You can manually create an error with:

  ```elixir
  Valpa.Error.new(%{
    validator: :sum,
    value: [4, 5, 6],
    field: :diceRolls,
    criteria: 20,
    text: "Sum must be exactly 20"
  })
  ```

  > This returns a `{:error, %Valpa.Error{...}}` tuple ready for use in custom validators.

  #### Setting the Field Later

  To associate an error with a field after creation:

  ```elixir
  Valpa.Error.new(%{...})
  |> Valpa.Error.at(:my_field)
  ```
  """

  defexception [:validator, :value, :field, :criteria, :text, :__trace__]

  @type t :: %__MODULE__{
          validator: atom() | nil,
          value: any() | nil,
          field: atom() | nil,
          criteria: any() | nil,
          text: String.t() | nil,
          __trace__: any() | nil
        }

  @impl true
  def message(%{
        validator: validator,
        value: value,
        field: field,
        criteria: criteria,
        text: text,
        __trace__: trace
      }) do
    trace_str = format_trace(trace)

    text =
      text ||
        ~s(expected: #{inspect(validator)}#{if(criteria, do: " of #{inspect(criteria)}")}, got: #{inspect(value)}#{if(field, do: " for field #{inspect(field)}")})

    """
    #{text}
    #{trace_str}
    """
  end

  defp format_trace(trace) do
    case trace do
      {:current_stacktrace, tr} -> Exception.format_stacktrace(tr)
      tr when is_list(tr) -> Exception.format_stacktrace(tr)
      _ -> "no stacktrace available"
    end
  end

  defp capture_trace() do
    {:current_stacktrace, trace} = Process.info(self(), :current_stacktrace)
    Enum.drop(trace, 1)
  end

  def new(fields) do
    %{struct(__MODULE__, fields) | __trace__: capture_trace()}
  end

  def at(%__MODULE__{} = error, field) do
    %{error | field: field}
  end
end
