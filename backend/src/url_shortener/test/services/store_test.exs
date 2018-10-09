defmodule Tests.UrlShortener.Services.Store do
  use ExUnit.Case, async: true

  alias UrlShortener.Data.Link
  alias UrlShortener.Services.Store.Impl, as: Store

  doctest Store

  setup_all do
    {:ok, pid} = Store.start_link []
    [pid: pid]
  end

  test "saves links", context do
    link = %Link{code: "1", long: "pig"}
    assert :ok = Store.create(context[:pid], link)
    assert {:ok, ^link} = Store.get(context[:pid], link.code)
  end

  test "lists all stored links", context do
    links = [
      %Link{code: "1", long: "pig"},
      %Link{code: "2", long: "god"},
      %Link{code: "3", long: "hedgehog"},
    ]

    Enum.map links, &Store.create(context[:pid], &1)

    assert ^links = Store.get_all(context.pid)
  end

  test "deletes a stored link", context do
    links = [
      %Link{code: "1", long: "pig"},
      %Link{code: "2", long: "god"},
      %Link{code: "3", long: "hedgehog"},
    ]

    Enum.map links, &Store.create(context[:pid], &1)

    assert ^links = Store.get_all(context.pid)

    Enum.map links, &Store.delete(context.pid, &1.code)

    assert [] = Store.get_all(context.pid)
  end
end
