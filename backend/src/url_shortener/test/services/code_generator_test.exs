defmodule Tests.UrlShortener.Services.CodeGenerator do
  use ExUnit.Case, async: true

  alias UrlShortener.Services.CodeGenerator

  doctest CodeGenerator

  test "generates unique codes" do
    first = CodeGenerator.initial()
    second = CodeGenerator.next(first)
    third = CodeGenerator.next(second)

    assert first != second
    assert second != third
  end

end
