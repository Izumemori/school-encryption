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
        encode: :boolean
      ],
      aliases:
      [
        k: :key,
        t: :text,
        d: :decode,
        e: :encode
      ]
    ]

    {opts, _, _} = OptionParser.parse(args, options)

    result = \
    case opts do
      [key: key, text: text, decode: true] ->
        decrypt(key, text)
      [key: key, text: text, encode: true] ->
        encrypt(key, text)
      _ ->
        {:error, "Invalid parameters"}
    end

    case result do
      {:error, x} ->
        IO.puts(:stderr, x)
      {:ok, x} ->
        IO.puts(x)
    end
  end
end
