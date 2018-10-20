defmodule UrlShortener.Services.CodeGenerator do
  @moduledoc """
  Generates short codes for Links
  """
  @initial 16_769_023
  @shift 16_769_023
  @period 1_073_676_287

  @hashids Hashids.new(
             salt: Application.get_env(:url_shortener, :secret_key),
             min_len: Application.get_env(:url_shortener, :code_min_length),
             alphabet: Application.get_env(:url_shortener, :code_alphabet)
           )

  def initial do
    numeric_to_string(@initial)
  end

  @spec next(prev_id :: String.t()) :: String.t()
  def next(prev_id) do
    numeric = string_to_numeric(prev_id)
    next_numeric = rotate(numeric)
    numeric_to_string(next_numeric)
  end

  @spec string_to_numeric(str_id :: String.t()) :: integer
  def string_to_numeric(str_id) do
    [numeric] = Hashids.decode!(@hashids, str_id)
    numeric
  end

  @spec numeric_to_string(num_id :: integer) :: String.t()
  def numeric_to_string(num_id) do
    Hashids.encode(@hashids, num_id)
  end

  @spec rotate(numeric_id :: integer) :: integer
  def rotate(numeric_id) do
    rem(numeric_id + @shift, @period)
  end
end
