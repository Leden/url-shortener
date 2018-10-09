defmodule Tests.UrlShortener.Http.Router do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias UrlShortener.Http.Router
  alias UrlShortener.Data.Link
  alias UrlShortener.Services.Store.Mock, as: Store

  def call(conn) do
    Router.call(conn, Router.init([]))
  end

  def json_body(conn), do: conn.resp_body |> Poison.decode!(keys: :atoms!)

  setup :verify_on_exit!

  test "get /" do
    resp = conn(:get, "/") |> call()

    assert 302 = resp.status
    assert {"location", "/index.html"} in resp.resp_headers
  end

  test "get /urls - empty" do
    Store
    |> expect(:get_all, fn _ -> [] end)

    resp = conn(:get, "/urls") |> call()

    assert 200 = resp.status
    assert [] = json_body(resp)
  end

  test "get /urls - one" do
    %{code: code, long: long} = link = %Link{code: "Af+//g",
                                             long: "http://example.com/foo/bar"}
    Store
    |> expect(:get_all, fn _ -> [link] end)

    resp = conn(:get, "/urls") |> call()

    assert 200 = resp.status
    assert [%{code: ^code, long: ^long}] = json_body(resp)
  end

  test "post /urls" do
    long = "http://example.com/foo"

    Store
    |> expect(:get_last_code, fn _ -> nil end)
    |> expect(:create, fn _, %{long: ^long} -> :ok end)

    resp = conn(:post, "/urls", %{"long" => long}) |> call()

    assert 201 = resp.status
    assert %{long: ^long} = json_body(resp)
  end

  test "get /urls/*code" do
    code = "Af+//g"
    long = "http://example.com/foo"

    Store
    |> expect(:get, fn _, ^code -> {:ok, %Link{code: code, long: long}} end)

    resp = conn(:get, "/urls/#{ code }") |> call()

    assert 200 = resp.status
    assert %{code: code, long: long} = json_body(resp)
  end

  test "delete /urls/*code" do
    code = "Af+//g"

    Store
    |> expect(:delete, fn _, ^code -> :ok end)

    resp = conn(:delete, "/urls/#{ code }") |> call()

    assert 204 = resp.status
    assert "" = resp.resp_body
  end

  test "get /*code" do
    code = "Af+//g"
    long = "http://example.com/foo"

    Store
    |> expect(:get, fn _, ^code -> {:ok, %Link{code: code, long: long}} end)

    resp = conn(:get, "/#{ code }") |> call()

    assert 302 = resp.status
    assert {"location", long} in resp.resp_headers
    assert "" = resp.resp_body
  end
end
