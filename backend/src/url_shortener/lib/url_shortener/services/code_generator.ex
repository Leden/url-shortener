defmodule UrlShortener.Services.CodeGenerator do
  @initial 16_769_023
  @shift 16_769_023
  @period 1_073_676_287

  def initial do
    numeric_to_string(@initial)
  end

  @spec next(prev_id :: String.t()) :: String.t()
  def next(prev_id) do
    numeric = string_to_numeric(prev_id)
    next_numeric = rotate(numeric)
    numeric_to_string(next_numeric)
  end

  def string_to_numeric(str_id) do
    {:ok, bytes} = Base.decode64(str_id, padding: false)
    <<numeric::32>> = bytes
    numeric
  end

  def numeric_to_string(num_id) do
    bytes = <<num_id::32>>
    Base.encode64(bytes, padding: false)
  end

  def rotate(numeric_id) do
    rem(numeric_id + @shift, @period)
  end
end
