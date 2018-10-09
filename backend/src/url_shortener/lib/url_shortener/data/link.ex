defmodule UrlShortener.Data.Link do
  @derive [Poison.Encoder]
  @enforce_keys [:code, :long]
  defstruct [:code, :long]
end
