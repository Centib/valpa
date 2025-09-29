# Changelog

## v0.1.2 (2025-09-29)

### Added

- New predicate `Valpa.Predicate.Validator.decimal_precision/2`:

  - Checks if a `Decimal` value has a scale **less than or equal to the given precision**.
  - Returns `false` if the value is not a `Decimal`.
  - Raises an error only if the `max_precision` argument is invalid (not a non-negative integer).
  - Useful for validating numbers where exact decimal places are required.

- New predicates `Valpa.Predicate.Validator.decimal_in_range_inclusive/2` and `decimal_in_range_exclusive/2`:

  - Check if a `Decimal` value falls within an inclusive or exclusive range, respectively.
  - Return `false` if the value is not a `Decimal`.
  - Raise errors only if the helper arguments (`min` or `max`) are invalid.

- Users now have additional high-level validators:

  - `Valpa.decimal_precision/2`
  - `Valpa.decimal_precision/3` (for map/struct)
  - `Valpa.maybe_decimal_precision/2`
  - `Valpa.maybe_decimal_precision/3` (for map/struct)
  - `Valpa.decimal_in_range_inclusive/2`
  - `Valpa.decimal_in_range_inclusive/3` (for map/struct)
  - `Valpa.maybe_decimal_in_range_inclusive/2`
  - `Valpa.maybe_decimal_in_range_inclusive/3` (for map/struct)
  - `Valpa.decimal_in_range_exclusive/2`
  - `Valpa.decimal_in_range_exclusive/3` (for map/struct)
  - `Valpa.maybe_decimal_in_range_exclusive/2`
  - `Valpa.maybe_decimal_in_range_exclusive/3` (for map/struct)

## v0.1.1 (2025-09-03)

### Changed

- `Valpa.Error` now respects runtime configuration for stacktrace inclusion:

  - Stacktraces are **enabled by default** in `:dev` and `:test`.
  - Stacktraces are **disabled by default** in `:prod`.
  - Users can override via application config:

    ```elixir
    config :valpa, :stacktrace, true  # force stacktraces
    config :valpa, :stacktrace, false # disable stacktraces
    ```

- `Valpa.Error.new/1` is runtime-safe and uses `Application.get_env/3` instead of `compile_env`, ensuring correct behavior in releases.

- `__trace__` is now optional and hidden in production by default for safer error reporting.

### Documentation

- Updated module documentation for `Valpa.Error` explaining:

  - Stacktrace defaults per environment.
  - How to override via user config.
  - Safe defaults for library consumers.

- README updated with a **stacktrace configuration section** for clarity.

### Development

- Refactored `Valpa.Error` to make stacktrace capture runtime-safe and configurable.
- Improved dev/test experience with stacktraces while keeping production errors clean.

## v0.1.0 (2025-08-04)

### Added

- Initial release of **Valpa** validation library for Elixir.
- Support for validating raw values, `{:ok, _}`, or `{:error, _}` tuples in pipelines with automatic error propagation.
- Built-in validators for common types: integer, float, string, boolean, decimal, lists, maps, and more.
- Support for optional (`maybe_`) and required variants of validators.
- Validation of relationships between map/struct fields (e.g., comparing keys).
- Custom validators support via modules and inline functions.
- Detailed structured error reporting with `Valpa.Error` including stacktrace capture (in dev/test).
- Predicate functions in `Valpa.Predicate.Validator` returning `true` or `false` for standalone checks.
- Comprehensive pipeline-friendly API for easy composition.
- No schema definitions required — works directly with maps or structs.
- Supports validation of list contents, unique lists, and value sets.
- Inclusive and exclusive key validation in maps.

### Documentation

- Complete README with usage examples, custom validator patterns, and error structure.
- API documentation published on HexDocs.

### Development

- Macro-based generation of validation functions from predicate logic for DRY code.
- Proper error trace capturing for better debugging.

For future releases: planned improvements include:

- More validators and richer predicate coverage.
- Schema integration.
- Improved error messaging.
- Proper `@spec` annotations and detailed documentation for every validation function.

_Created and maintained by [Centib](https://github.com/Centib)._
