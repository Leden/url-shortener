defmodule Tests.UrlShortener.Services.Cache do
  use ExUnit.Case, async: true

  alias UrlShortener.Data.Link
  alias UrlShortener.Services.Cache.GenServerCache, as: Cache

  doctest Cache

  setup do
    {:ok, pid} = Cache.start_link([])
    {:ok, [pid: pid]}
  end

  test "saves links", context do
    link = %Link{code: "1", long: "pig"}
    assert :ok = Cache.create(context[:pid], link)
    assert {:ok, ^link} = Cache.get(context[:pid], link.code)
  end

  test "lists all stored links", context do
    links = [
      %Link{code: "1", long: "pig"},
      %Link{code: "2", long: "dog"},
      %Link{code: "3", long: "hedgehog"}
    ]

    Enum.map(links, &Cache.create(context[:pid], &1))

    assert ^links = Cache.get_all(context.pid)
  end

  test "deletes a stored link", context do
    links = [
      %Link{code: "1", long: "pig"},
      %Link{code: "2", long: "dog"},
      %Link{code: "3", long: "hedgehog"}
    ]

    Enum.map(links, &Cache.create(context[:pid], &1))

    Enum.map(links, &Cache.delete(context[:pid], &1.code))

    assert [] = Cache.get_all(context[:pid])
  end

  test "returns last added code", context do
    links = [
      %Link{code: "3", long: "hedgehog"},
      %Link{code: "1", long: "pig"},
      %Link{code: "2", long: "dog"}
    ]

    Enum.map(links, &Cache.create(context[:pid], &1))

    assert "2" = Cache.get_last_code(context[:pid])
  end
end
