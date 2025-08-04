defmodule Valpa.Predicate.MaybeGenerator do
  @moduledoc false
  defmacro __before_compile__(env) do
    module = env.module

    functions =
      module
      |> Module.definitions_in(:def)
      |> Enum.reject(fn {name, _arity} -> String.starts_with?(Atom.to_string(name), "maybe_") end)

    maybe_functions =
      for {name, arity} <- functions do
        args = Macro.generate_arguments(arity, module)

        quote do
          def unquote(:"maybe_#{name}")(unquote_splicing(args)) do
            case unquote(hd(args)) do
              nil -> true
              _ -> apply(__MODULE__, unquote(name), unquote(args))
            end
          end
        end
      end

    quote do
      (unquote_splicing(maybe_functions))
    end
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end
end
