defmodule ExtreamSeek do

  def main(argv) do
    argv
    |> parse_args
    |> process
    |> formatter
    |> Enum.join "\n"
    |> IO.puts
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases: [h:     :help])

    case parse do
      {[help: true], _, _}
        -> :help

      {_, [dir, word, process_num, depth], _}
        -> { dir, word, String.to_integer(process_num), String.to_integer(depth) }
      _ -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    usage: extreamseek <dir> <word> <process_num> depth]
    """
  end

  defp process({ dir, word, process_num, depth }) do
    ExtreamSeek.Scheduler.run([dir], process_num, word, depth)
  end

  defp formatter(results) do
    results
    |> Enum.map(fn (result) -> result.path end)
  end
end
