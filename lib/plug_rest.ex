defmodule PlugRest do

  @moduledoc """
  A DSL to define a resource-oriented REST Plug.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Plug.Builder
      import PlugRest

      plug :rest

      defp rest(%{path_info: path_info} = conn, opts) do
        do_match(conn, Enum.map(conn.path_info, &URI.decode/1))
      end
    end
  end

  defmacro resource(path, handler, handler_state \\ []) do
    add_route(path, handler, handler_state)
  end

  defp add_route(path, handler, handler_state) do
    {_vars, match} = Plug.Router.Utils.build_path_match(path)
    quote do
      defp do_match(conn, unquote(match)) do
        PlugRest.Resource.upgrade(conn, unquote(handler), unquote(handler_state))
      end
    end
  end
end
