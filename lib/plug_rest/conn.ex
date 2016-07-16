defmodule PlugRest.Conn do
  import Plug.Conn
  import Plug.Conn.Utils

  def parse_req_header(conn, header) when header == "content-type" do
    [content_type] = get_req_header(conn, header)
    {:ok, type, subtype, params} = content_type(content_type)

    ## Ensure that any value of charset is lowercase
    params2 = case Map.fetch(params, "charset") do
                :error ->
                  params
                {:ok, charset} ->
                  Map.put(params, "charset", String.downcase(charset))
              end

    {type, subtype, params2}
  end

  def parse_req_header(conn, header) when header == "accept" do
    get_req_header(conn, header)
    |> parse_accept_header
    |> format_media_types
  end

  def parse_req_header(conn, header) when header == "if-match" do
    case get_req_header(conn, header) do
      [] -> []
      ["*"] -> [:*]
      [x] -> String.split(x)
    end
  end

  def parse_req_header(conn, header) when header == "if-none-match" do
    case get_req_header(conn, header) do
      [] -> []
      ["*"] -> [:*]
      [etags] ->
        etags
        |> String.split
        |> Enum.map(fn(e) ->
          {etag} = List.to_tuple(:cowboy_http.entity_tag_match(e))
          etag
        end)
    end
  end

  def parse_req_header(conn, header) do
    get_req_header(conn, header)
    |> parse_header
    |> reformat_tags
  end

  def parse_accept_header([]) do
    []
  end

  def parse_accept_header([accept]) when is_binary(accept) do
    accept
    |> Plug.Conn.Utils.list
    |> Enum.map(fn "*"->"*/*"; e -> e end)
    |> Enum.map(&Plug.Conn.Utils.media_type/1)
    |> Enum.map(fn({:ok, t, s, p}) -> {t, s, p} end)
  end

  def format_media_types(media_types) do
    media_types
    |> Enum.map(fn({type, subtype, params}) ->
      quality = case Float.parse(params["q"] || "1") do
        {q, _} -> q
        _ -> 1 end
      {{type, subtype, params}, quality, %{}} end)
  end

  defp parse_header([]) do
    []
  end

  defp parse_header([header]) when is_binary(header) do
    Plug.Conn.Utils.list(header)
    |> Enum.map(fn(x) ->
      {hd(String.split(x, ";")), Plug.Conn.Utils.params(x)}
    end)
  end

  defp reformat_tags(tags) do
    tags
    |> Enum.map(fn({tag, params}) ->
      quality = case Float.parse(params["q"] || "1") do
        {q, _} -> q
        _ -> 1 end
      {tag, quality} end)
  end

end
