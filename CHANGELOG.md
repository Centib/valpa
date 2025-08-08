# Changelog

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

*Created and maintained by [Centib](https://github.com/Centib).*
