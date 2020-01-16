defmodule Base64 do
  use Bitwise

  @spec validate(bitstring) :: boolean
  def validate(input) when byte_size(input) |> Kernel.rem(4) == 0 do
    input
    |> to_charlist()
    |> Enum.map(&get_num_from_ascii/1)
    |> Enum.filter(fn a -> a == nil end)
    |> Enum.any?()
    |> Kernel.not()
  end

  def validate(input) when byte_size(input) |> Kernel.rem(4) != 0, do: false

  def encode(input) do
    input
    |> to_charlist
    |> Enum.map(fn a ->
      case <<a :: utf8>> do
        <<a :: size(8), b :: size(8), c :: size(8), d :: size(8)>> ->
          [a, b, c, d]
        <<a :: size(8), b :: size(8), c :: size(8)>> ->
          [a, b, c]
        <<a :: size(8), b :: size(8)>> ->
          [a, b]
        <<a :: size(8)>> ->
          [a]
      end
    end)
    |> List.flatten()
    |> Enum.filter(fn a -> a != 0 end)
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.zip(&1, 2..0))
    |> Enum.map(fn list ->
      Enum.map(list, fn {char, index} -> char <<< index*8 end)
      |> Enum.reduce(fn(shifted, acc) -> acc ||| shifted end)
    end)
    |> Enum.map(fn num -> Enum.map(3..0, fn a ->
        num >>> 6*a &&& 0b111111
      end)
    end)
    |> List.flatten()
    |> Enum.map(&get_ascii_char/1)
    |> List.to_string()
  end

  def decode(input) do
    to_charlist(input)
    |> Enum.map(&get_num_from_ascii/1)
    |> Enum.chunk_every(4)
    |> Enum.map(fn list ->
      Enum.zip(list, 3..0)
      |> Enum.map(fn {num, index} -> num <<< 6 * index end)
      |> Enum.reduce(fn(num, acc) -> acc ||| num end)
    end)
    |> Enum.map(fn num -> Enum.map(2..0, fn a ->
        num >>> 8*a &&& 0b11111111
      end)
      |> Enum.filter(fn a -> a != 0 end)
    end)
    |> List.flatten()
    |> Enum.map(fn a -> <<a>> end)
    |> to_string()
  end

  defp get_num_from_ascii(input) do
    cond do
      input >= ?A and input <= ?Z -> input - ?A
      input >= ?a and input <= ?z -> input - ?a + 26
      input >= ?0 and input <= ?9 -> input - ?0 + 52
      input == ?+ -> 62
      input == ?/ -> 63
      true -> 0
    end
  end

  defp get_ascii_char(input) do
    cond do
      input >= 0 and input <= 25 -> <<input + ?A :: utf8>>
      input >= 26 and input <= 51 -> <<input + ?a - 26 :: utf8>>
      input >= 52 and input <= 61 -> <<input + ?0 - 52 :: utf8>>
      input == 62 -> <<?+ :: utf8>>
      input == 63 -> <<?/ :: utf8>>
      true -> '='
    end
  end
end
