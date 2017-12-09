defmodule Tokenizer do
  def run(input, :a) do
    input |> scan |> Enum.reduce(0, fn
      {:group, n}, a -> a + n
      {_, _}, a -> a
    end)
  end

  def run(input, :b) do
    input |> scan |> Enum.reduce(0, fn
      {:garbage, n}, a -> a + n
      {_, _}, a -> a
    end)
  end

  defp scan(input, depth \\ 0, res \\ [])
  defp scan("", _depth, res), do: res
  defp scan("{" <> tail, depth, res), do: tail |> scan(depth + 1, res)
  defp scan("}" <> tail, depth, res), do: tail |> scan(depth - 1, [{:group, depth} | res])
  defp scan("," <> tail, depth, res), do: tail |> scan(depth, res)
  defp scan("<" <> garbage, depth, res) do
    {tail, num_chars} = garbage |> scan_garbage
    tail |> scan(depth, [{:garbage, num_chars} | res])
  end
  defp scan(<<x::8>> <> _, _depth, _res), do: raise "Unexpected token: #{x}"

  defp scan_garbage(input, num_chars \\ 0)
  defp scan_garbage("", _), do: raise "Unexpected end of garbage!"
  defp scan_garbage(">" <> tail, num_chars), do: {tail, num_chars}
  defp scan_garbage("!" <> <<_::8>> <> garbage, num_chars), do: garbage |> scan_garbage(num_chars)
  defp scan_garbage(<<_::8>> <> garbage, num_chars), do: garbage |> scan_garbage(num_chars + 1)
end

part = System.argv |> Enum.at(0) |> String.to_atom
:stdio |> IO.read(:all) |> String.trim |> Tokenizer.run(part) |> IO.inspect
