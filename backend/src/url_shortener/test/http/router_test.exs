defmodule Tests.UrlShortener.Adapters.Http.Router do
  use ExUnit.Case, async: true
  use Plug.Test

  import Mox

  alias UrlShortener.Adapters.Http.Router
  alias UrlShortener.Data.Link
  alias UrlShortener.Services.Cache.Mock, as: Cache

  def call(conn) do
    Router.call(conn, Router.init([]))
  end

  def json_body(conn), do: conn.resp_body |> Poison.decode!(keys: :atoms!)

  setup :verify_on_exit!

  describe "GET /" do
    test "redirects to /index.html" do
      resp = conn(:get, "/") |> call()

      assert 302 = resp.status
      assert {"location", "/index.html"} in resp.resp_headers
    end
  end

  describe "GET /index.html" do
    test "serves static index.html" do
      resp = conn(:get, "/index.html") |> call()

      assert 200 = resp.status
      assert "<html>NOTHING HERE FOR NOW</html>\n" = resp.resp_body
    end
  end

  describe "GET /urls" do
    test "returns empty list" do
      Cache
      |> expect(:get_all, fn _ -> [] end)

      resp = conn(:get, "/urls") |> call()

      assert 200 = resp.status
      assert [] = json_body(resp)
    end

    test "returns a list of one url" do
      %{code: code, long: long} = link = %Link{code: "Afg", long: "http://example.com/foo/bar"}

      Cache
      |> expect(:get_all, fn _ -> [link] end)

      resp = conn(:get, "/urls") |> call()

      assert 200 = resp.status
      assert [%{code: ^code, long: ^long}] = json_body(resp)
    end

    test "returns a list of two urls" do
      %{code: code, long: long} = link = %Link{code: "Afg", long: "http://example.com/foo/bar"}

      Cache
      |> expect(:get_all, fn _ -> [link, link] end)

      resp = conn(:get, "/urls") |> call()

      assert 200 = resp.status
      assert [%{code: ^code, long: ^long}, %{code: ^code, long: ^long}] = json_body(resp)
    end
  end

  describe "POST /urls" do
    test "creates a new link" do
      long = "http://example.com/foo"

      Cache
      |> expect(:get_last_code, fn _ -> nil end)
      |> expect(:create, fn _, %Link{long: ^long} -> :ok end)

      resp = conn(:post, "/urls", %{"long" => long}) |> call()

      assert 201 = resp.status
      assert %{long: ^long} = json_body(resp)
    end

    test "responds with error on invalid input: missing parameter" do
      resp = conn(:post, "/urls", %{}) |> call()

      assert 400 = resp.status
      assert %{long: ["can't be blank"]} = json_body(resp)
    end

    test "responds with error on invalid input: wrong url format" do
      resp = conn(:post, "/urls", %{long: "just-random-letters"}) |> call()

      assert 400 = resp.status
      assert %{long: ["scheme can't be blank", "host can't be blank"]} = json_body(resp)
    end

    test "responds with error on invalid input: missing scheme from url" do
      resp = conn(:post, "/urls", %{long: "//example.com"}) |> call()

      assert 400 = resp.status
      assert %{long: ["scheme can't be blank"]} = json_body(resp)
    end

    test "responds with error on invalid input: missing host from url" do
      resp = conn(:post, "/urls", %{long: "http://"}) |> call()

      assert 400 = resp.status
      assert %{long: ["host can't be blank"]} = json_body(resp)
    end
  end

  describe "GET /urls/*code" do
    test "returns the requested link metadata" do
      code = "Afg"
      long = "http://example.com/foo"

      Cache
      |> expect(:get, fn _, ^code -> {:ok, %Link{code: code, long: long}} end)

      resp = conn(:get, "/urls/#{code}") |> call()

      assert 200 = resp.status
      assert %{code: code, long: long} = json_body(resp)
    end

    test "returns 404 if no link with given code exists" do
      code = "foobar"

      Cache
      |> expect(:get, fn _, ^code -> :error end)

      resp = conn(:get, "/urls/#{code}") |> call()

      assert 404 = resp.status
      assert %{error: "Link not found", code: real_code} = json_body(resp)
    end
  end

  describe "DELETE /urls/*code" do
    test "deletes the link with given code" do
      code = "Afg"

      Cache
      |> expect(:delete, fn _, ^code -> :ok end)

      resp = conn(:delete, "/urls/#{code}") |> call()

      assert 204 = resp.status
      assert "" = resp.resp_body
    end
  end

  describe "GET /*code" do
    test "redirects to the long url of the link" do
      code = "Afg"
      long = "http://example.com/foo"

      Cache
      |> expect(:get, fn _, ^code -> {:ok, %Link{code: code, long: long}} end)

      resp = conn(:get, "/#{code}") |> call()

      assert 302 = resp.status
      assert {"location", long} in resp.resp_headers
      assert "" = resp.resp_body
    end

    test "returns 404 if no lonk with given code exists" do
      code = "Afg"

      Cache
      |> expect(:get, fn _, ^code -> :error end)

      resp = conn(:get, "/#{code}") |> call()

      assert 404 = resp.status
      assert "<html><h1>LINK DOES NOT EXIST</h1></html>" = resp.resp_body
    end
  end
end
