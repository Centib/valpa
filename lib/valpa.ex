defmodule Valpa do
  @moduledoc """
    Valpa is a composable validation library for Elixir.

  It supports validation of raw values, `{:ok, _}` and `{:error, _}` tuples with
  pipelined field validations and automatic error propagation.

  Features include:

  - Simple, reusable validation functions for values and maps/structs
  - Optional and required variants for all validators
  - Extensible with custom validators
  - Detailed error reporting with rich metadata

  For usage examples and full documentation, see:

  - [README](https://github.com/Centib/valpa#readme)
  - [HexDocs](https://hexdocs.pm/valpa)
  """

  use Valpa.Generator
end
