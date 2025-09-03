# Valpa

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
[![Hex.pm](https://img.shields.io/hexpm/v/valpa.svg)](https://hex.pm/packages/valpa)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/valpa/)

**Valpa** is a composable validation library for Elixir. It works with raw values, `{:ok, _}`, or `{:error, _}` tuples in pipelines. It offers pipelined field validation, automatic error propagation, and structured error reporting.

Valpa provides simple, reusable validation functions for individual values or relationships between fields in a map or struct.

## Why?

- **Pipeline-friendly** — validate values, `{:ok, _}`, or `{:error, _}` directly in Elixir pipelines.
- **No schemas required** — works with plain maps, structs, or raw values.
- **Optional (`maybe_`) and required variants** for all validators.
- **Built-in validators** for numbers, strings, booleans, lists, maps, and more.
- **List and map content checks** — uniqueness, value sets, key inclusion/exclusion.
- **Custom validators** — easily extend with your own rules.
- **Detailed errors** — structured output with optional stacktrace for debugging.
- **Predicate functions** — standalone checks returning `true` or `false`.

## Installation

Add `:valpa` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:valpa, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Usage

Let’s say you need to validate a person struct:

```elixir
defmodule Person do
  defstruct [
    :name, :age, :height, :money, :has_hat, :won, :lose,
    :dice_rolls, :hat_color, :car, :bike, :school, :work
  ]

  def validate(p) do
    p
    |> Valpa.string(:name)
    |> Valpa.integer(:age)
    |> Valpa.maybe_float(:height)
    |> Valpa.decimal(:money)
    |> Valpa.boolean(:has_hat)
    |> Valpa.integer(:won)
    |> Valpa.integer(:lose)
    |> Valpa.map_compare_int_keys({:>, :won, :lose})
    |> Valpa.list_of_type(:dice_rolls, :integer)
    |> Valpa.value_of_values(:hat_color, [:RED, :GREEN, :BLUE])
    |> Valpa.maybe_value_or_uniq_list_of_values(:car, [:BMW, :AUDI, :FORD])
    |> Valpa.maybe_uniq_list_of_type(:bike, :string)
    |> Valpa.map_inclusive_keys([:car, :bike])
    |> Valpa.maybe_string(:school)
    |> Valpa.maybe_string(:work)
    |> Valpa.map_exclusive_keys([:school, :work])
  end
end
```

### Valid input:

```elixir
defmodule Bernard do
  def create do
    %Person{
      name: "Bernard",
      age: 34,
      height: 183.5,
      money: Decimal.new("53.8"),
      has_hat: true,
      won: 5,
      lose: 3,
      dice_rolls: [1, 4, 4, 5, 2, 3],
      hat_color: :GREEN,
      car: :FORD,
      bike: ["Old", "Electric"],
      school: "MIT"
    }
  end
end

Bernard.create() |> Person.validate()
# => {:ok, %Person{...}}
```

### Invalid input (wrong type):

```elixir
defmodule InvalidBernard do
  def create do
    %Person{age: "34", name: "Bernard", ...}
  end
end

InvalidBernard.create() |> Person.validate()
# => {:error, %Valpa.Error{validator: :integer, value: "34", field: :age, ...}}
```

### Invalid input (field relationship):

```elixir
defmodule AnotherInvalidBernard do
  def create do
    %Person{won: 5, lose: 11, ...}
  end
end

AnotherInvalidBernard.create() |> Person.validate()
# => {:error, %Valpa.Error{validator: :map_compare_int_keys, criteria: {:>, :won, :lose}, ...}}
```

## Optional vs Required

Validators come in two variants:

- `Valpa.integer/2` — required
- `Valpa.maybe_integer/2` — optional (passes on `nil`)

Also available for types: `string`, `float`, `decimal`, `boolean`, `list_of_type`, `value_of_values`, etc.

## Custom Validators

Valpa supports custom validation in two ways:

- **Module-based validation** via `Valpa.Custom.validator`
- **Function-based validation** via `Valpa.Custom.validate`

### Option 1: Custom validator module (on field)

```elixir
defmodule DiceRolls do
  @behaviour Valpa.CustomValidator

  def validate(value) do
    if Enum.sum(value) == 20, do: :ok, else: {:error, Valpa.Error.new(...) }
  end
end

# In validation:
# ...
|> Valpa.Custom.validator(:dice_rolls, DiceRolls)
```

### Option 2: Custom validator module (on full struct)

```elixir
defmodule WonLose do
  @behaviour Valpa.CustomValidator

  def validate(%{won: won, lose: lose}) do
    if won + lose == 10, do: :ok, else: {:error, Valpa.Error.new(...) }
  end
end

# ...
|> Valpa.Custom.validator(WonLose)
```

### Option 3: Inline validation function

```elixir
defmodule FieldsSumEqualsTen do
  def validate(data, a, b) do
    if Map.get(data, a) + Map.get(data, b) == 10, do: :ok, else: {:error, Valpa.Error.new(...) }
  end
end

# ...
|> Valpa.Custom.validate(&FieldsSumEqualsTen.validate(&1, :age, :won))
```

## Error Struct

Errors are returned as `%Valpa.Error{}` with fields:

- `:validator` — name of the validator
- `:value` — the invalid value (or whole struct for relationship checks)
- `:field` — field being validated (if applicable)
- `:criteria` — criteria info like `{:>, :a, :b}` or `%{min: 0}`
- `:text` — optional message (useful for custom validators)
- `:__trace__` — stacktrace, shown only in dev/test

> See [`Valpa.Error`](`Valpa.Error`) for full structure and how to build custom errors.

## Stacktrace Configuration

Valpa can include stacktraces in `%Valpa.Error{}` for debugging.

- **Default behavior:**

  - `:dev` and `:test` → stacktraces included
  - `:prod` → stacktraces omitted

- **Optional override:**  
  If you want to change this behavior, add the following to your **application config**:

```elixir
# enable stacktraces (for dev/test or debugging)
config :valpa, :stacktrace, true

# disable stacktraces (recommended for prod)
config :valpa, :stacktrace, false
```

> ⚠️ You usually **don’t have to set this** — Valpa applies safe defaults automatically.
> Stacktraces are mainly for debugging and internal error inspection; in production they are hidden by default.

## Predicate Functions

All built-in validators in Valpa are based on simple predicate functions defined in `Valpa.Predicate.Validator`. These functions return `true` or `false`, making them useful on their own when you don’t need full validation:

```elixir
Valpa.Predicate.Validator.integer(5)
# => true

Valpa.Predicate.Validator.integer("not a number")
# => false
```

## Documentation

Full API docs: [https://hexdocs.pm/valpa](https://hexdocs.pm/valpa)

## Contributing

Contributions are welcome via issues or pull requests.
Created and maintained by [Centib](https://github.com/Centib).

## License

MIT License. See [LICENSE.md](LICENSE.md).
