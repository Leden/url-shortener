defmodule UrlShortener.Data.Link do
  @moduledoc """
  Struct describing the shortened url.
  """
  @derive [Poison.Encoder]
  @enforce_keys [:code, :long]
  defstruct [:code, :long]
end
