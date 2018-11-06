defmodule UrlShortener.Adapters.Http.Router do
  use Plug.Router

  alias Ecto.Changeset

  alias UrlShortener.Adapters.Http.Schemas
  alias UrlShortener.Data.Link
  alias UrlShortener.Services.CodeGenerator

  @cache Application.get_env(:url_shortener, :cache_module)

  plug(Corsica, Application.get_env(:url_shortener, :corsica))

  plug(Plug.Static,
    at: "/",
    from: :url_shortener,
    only: ~w(index.html assets)
  )

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_header("location", "/index.html")
    |> send_resp(302, "")
  end

  get "/urls" do
    body = @cache.get_all(:cache) |> Poison.encode!()

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
  end

  post "/urls" do
    with {:ok, %{long: long}} <- validate(conn.params, Schemas.CreateUrl) do
      prev_code = @cache.get_last_code(:cache)
      code = CodeGenerator.next(prev_code || CodeGenerator.initial())
      link = %Link{code: code, long: long}

      :ok = @cache.create(:cache, link)

      body = Poison.encode!(link)

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(201, body)
    else
      {:error, error} ->
        body = Poison.encode!(error)

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(400, body)
    end
  end

  get "/urls/*code" do
    with {:ok, link} <- @cache.get(:cache, hd(code)) do
      body = Poison.encode!(link)

      conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, body)
    else
      :error ->
        body = Poison.encode!(%{error: "Link not found", code: hd(code)})

        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(404, body)
    end
  end

  delete "/urls/*code" do
    :ok = @cache.delete(:cache, hd(code))

    conn
    |> send_resp(204, "")
  end

  get "/*code" do
    with {:ok, %Link{long: long}} <- @cache.get(:cache, hd(code)) do
      conn
      |> put_resp_header("location", long)
      |> send_resp(302, "")
    else
      :error ->
        conn
        |> send_resp(404, "<html><h1>LINK DOES NOT EXIST</h1></html>")
    end
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  @spec validate(params :: map(), schema :: atom()) :: {:error, map()} | {:ok, map()}
  def validate(params, schema) do
    changeset = schema.changeset(struct(schema), params)

    if changeset.valid? do
      {:ok, Changeset.apply_changes(changeset)}
    else
      errors =
        Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)

      {:error, errors}
    end
  end
end
