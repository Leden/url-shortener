defmodule UrlShortener.Http.Router do
  use Plug.Router

  alias UrlShortener.Data.Link
  alias UrlShortener.Services.CodeGenerator

  @store Application.get_env :url_shortener, :store_module


  plug Corsica, Application.get_env(:url_shortener, :corsica)

  plug Plug.Static,
    at: "/",
    from: :url_shortener,
    only: ~w(index.html assets)

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_header("location", "/index.html")
    |> send_resp(302, "")
  end

  get "/urls" do
    body = @store.get_all(:store) |> Poison.encode!()

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
  end

  post "/urls" do
    long = conn.params["long"]
    prev_code = @store.get_last_code(:store)
    code = CodeGenerator.next(prev_code || CodeGenerator.initial())
    link = %Link{code: code, long: long}

    :ok = @store.create(:store, link)

    body = Poison.encode!(link)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(201, body)
  end

  get "/urls/*code" do
    "/urls/" <> real_code = conn.request_path
    {:ok, link} = @store.get(:store, real_code)
    body = Poison.encode!(link)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
  end

  delete "/urls/*code" do
    "/urls/" <> real_code = conn.request_path
    :ok = @store.delete(:store, real_code)

    conn
    |> send_resp(204, "")
  end

  get "/*code" do
    "/" <> real_code = conn.request_path
    {:ok, %Link{long: long}} = @store.get(:store, real_code)

    conn
    |> put_resp_header("location", long)
    |> send_resp(302, "")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
