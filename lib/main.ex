defmodule Main do
  import Encryption

  @spec main([binary]) :: :ok
  def main(args) do
    options = \
    [
      switches:
      [
        key: :string,
        text: :string,
        decode: :boolean,
        encode: :boolean,
        help: :boolean
      ],
      aliases:
      [
        k: :key,
        t: :text,
        d: :decode,
        e: :encode,
        h: :help
      ],
      help:
      [
        key: "The key to use for encryption/decryption",
        text: "The encrypted string to be decrypted or the plaintext string to be encrypted",
        decode: "Flag to indicate if the string should be decoded",
        encode: "Flag to indicate if the string should be encoded",
        help: "Prints this help"
      ]
    ]

    {opts, _, _} = OptionParser.parse(args, options)

    result = \
    case opts do
      [key: _key, text: _text, decode: _decode, encode: _encode] ->
        print_help(options)
      [key: key, text: text, decode: true] ->
        decrypt(key, text)
      [key: key, text: text, encode: true] ->
        encrypt(key, text)
      [key: key, text: text] ->
        encrypt(key, text)
      [help: true] ->
        print_help(options)
      _ ->
        print_help(options)
    end

    case result do
      {:error, x} ->
        IO.puts(:stderr, x)
        :ok
      {:ok, x} ->
        IO.puts(x)
        :ok
    end
  end

  defp print_help(options) do
    result = \
    "Usage: encryption [options]\n\n" <>
    "## General options\n" <>
    for {key, _key} <- options[:switches], into: "" do
      aliases = \
      for {alias, _key} <- options[:aliases] |> Enum.filter(fn a -> a |> elem(1) == key end), into: "" do
        "-#{alias}, "
      end

      "    #{aliases}--#{key}\t#{options[:help][key]}\n"
    end
    {:ok, result}
  end
end
