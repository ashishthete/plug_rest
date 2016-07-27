defmodule PlugRest.Router do

  @moduledoc """
  A DSL to supplement Plug Router with a resource-oriented routing algorithm.
  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Plug.Router
      import PlugRest.Router

      plug :match
      plug :dispatch
    end
  end

  defmacro resource(path, handler, handler_state \\ []) do
    add_resource(path, handler, handler_state)
  end

  defp add_resource(path, handler, handler_state) do
    {vars, _match} = Plug.Router.Utils.build_path_match(path)

    binding = for var <- vars do
      {Atom.to_string(var), Macro.var(var, nil)}
    end

    quote do
      match unquote(path) do

        connection = var!(conn)

        params =
          case connection.params do
            %Plug.Conn.Unfetched{} -> %{}
            p -> p
          end

        # Using conn.params to store path params is deprecated
        # Save any dynamic path segments into conn.params key/value pairs
        params2 =
          Enum.reduce(
            unquote(binding),
            params,
            fn({k,v}, p) -> Map.put(p, k, v) end
          )

        conn2 = %{connection | params: params2}
        conn3 = conn2 |> put_private(:plug_rest_path_params, params2)
        PlugRest.Resource.upgrade(conn3, unquote(handler), unquote(handler_state))
      end
    end
  end
end
