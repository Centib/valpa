defmodule Valpa.Generator do
  @moduledoc false
  import Loe

  defmodule Validator do
    @moduledoc false
    def validate(val, predicate, name, crit \\ nil) do
      if predicate.(val) do
        {:ok, val}
      else
        {:error,
         Valpa.Error.new(%{
           validator: name,
           value: val,
           field: nil,
           criteria: crit
         })}
      end
    end

    def validate_map(%{} = map, predicate, name, key, crit \\ nil) do
      if predicate.(map) do
        {:ok, map}
      else
        {:error,
         Valpa.Error.new(%{
           validator: name,
           value: Map.fetch!(map, key),
           field: key,
           criteria: crit
         })}
      end
    end
  end

  defmacro __using__(_opts) do
    functions =
      Valpa.Predicate.Validator.module_info(:exports)
      |> Enum.reject(fn {name, _arity} -> name in [:__info__, :module_info] end)

    {no_arg, with_arg} =
      Enum.split_with(functions, fn {_name, arity} -> arity == 1 end)

    quote do
      # no-arg validators
      unquote_splicing(
        for {name, _} <- no_arg do
          quote do
            def unquote(name)(input) do
              predicate = fn val -> Valpa.Predicate.Validator.unquote(name)(val) end
              name = unquote(name)
              input ~>> Validator.validate(predicate, name)
            end

            def unquote(name)(input, key) do
              predicate = fn map ->
                Valpa.Predicate.Validator.unquote(name)(Map.fetch!(map, key))
              end

              name = unquote(name)
              input ~>> Validator.validate_map(predicate, name, key)
            end
          end
        end
      )

      # arg-taking validators
      unquote_splicing(
        for {name, _} <- with_arg do
          quote do
            def unquote(name)(input, crit) do
              predicate = fn val -> Valpa.Predicate.Validator.unquote(name)(val, crit) end
              name = unquote(name)
              input ~>> Validator.validate(predicate, name, crit)
            end

            def unquote(name)(input, key, crit) do
              predicate = fn map -> Valpa.Predicate.Validator.unquote(name)(Map.fetch!(map, key), crit) end
              name = unquote(name)
              input ~>> Validator.validate_map(predicate, name, key, crit)
            end
          end
        end
      )
    end
  end
end
