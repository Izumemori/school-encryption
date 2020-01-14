defmodule Encryption do
  use Bitwise
  import Base

  @typedoc """
    A key used for encryption and decryption
  """
  @type key :: String.t()

  @typedoc """
    A string providing reason for error
  """
  @type reason :: String.t()

  @typedoc """
    A string to decode/encode
  """
  @type input :: String.t()

  @typedoc """
    The plaintext result string
  """
  @type plaintext :: String.t()

  @typedoc """
    The base64 encoded encrypted string
  """
  @type encrypted :: String.t()

  @spec decrypt!(key, input) :: plaintext
  def decrypt!(key, text) do
    with {:ok, res} <- decrypt(key, text) do
      res
    else
      _ -> raise Exception.message("Decoding failed")
    end
  end

  @spec encrypt!(key, input) :: encrypted
  def encrypt!(key, text) do
    with {:ok, res} <- encrypt(key, text) do
      res
    else
     _ -> raise Exception.message("Encoding failed")
    end
  end

  @spec decrypt(key, input) :: {:ok, plaintext} | {:error, reason}
  def decrypt(key, text) do
    with {:ok, raw_text_charlist} <- decode64(text) do # Try get raw bitstring
      text_charlist = \
      raw_text_charlist
      |> to_charlist() # Get bytes
      |> Enum.with_index() # Add indexes

      key_charlist = \
      key
      |> to_charlist() # Get bytes
      |> Enum.with_index()

      key_length = \
      key_charlist
      |> Enum.count() # Cache count

      byte_arr = \
      for {t, i} <- text_charlist, into: [] do
        key_charlist
        |> Enum.at(rem(i, key_length))
        |> elem(0) # Get only the value, not the index
        |> Kernel.-(t)
        |> Kernel.abs() # Codepoints can't have negative components
      end

      res = \
      byte_arr
      |> Enum.chunk_every(4)
      |> Enum.map(fn a ->
        [first, second, third, fourth] = a
        <<first, second, third, fourth>>
      end) # Create one bitstring for every 4 values in the array

      case res |> :unicode.characters_to_binary({:utf32, :big}) do
        {:error, _s, _data} ->
          {:error, "Could not decode string"}
        x ->
          {:ok, x}
      end # Try convert to unicode bitstring
    else
      _ -> {:error, "Invalid input"}
    end # Return :error if couldn't convert base64 string to raw bytes
  end

  @spec encrypt(key, input) :: {:ok, encrypted}
  def encrypt(key, text) do
    text_charlist = \
    text
    |> to_charlist()
    |> Enum.map(fn a ->
      <<first, second, third, fourth>> = <<a :: utf32>>
      [first, second, third, fourth]
    end) # Expand bitstring and add the 4 values as an enum to the enum
    |> List.flatten()
    |> Enum.with_index() # Add index

    key_charlist = \
    key
    |> to_charlist()
    |> Enum.with_index() # Add index

    key_length = \
    key_charlist
    |> Enum.count() # Cache key length

    byte_arr = \
    for {t, i} <- text_charlist, into: [] do
      key_charlist
      |> Enum.at(rem(i, key_length))
      |> elem(0) # Get only the value, not the index
      |> Kernel.+(t)
    end

    {:ok, encode64(byte_arr |> to_string())} # Convert bytes to base64 byte enum and then to string
  end
end
