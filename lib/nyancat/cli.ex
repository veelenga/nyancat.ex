defmodule Nyancat.Cli do
  def main(argv) do
    Process.flag(:trap_exit, true)

    { options, _ } = OptionParser.parse! argv,
      switches: [notime: :boolean],
      aliases: [n: :notime]

    Nyancat.start(options ++ term_dimenstions())
  rescue
    _ in OptionParser.ParseError -> show_help()
    e -> handle_error e
  end

  defp show_help do
    """
    Usage: nyancat [options]
    \t -h             Shows this help
    \t -n, --notime   Don't show the time nyaned
    """
    |> IO.puts

    exit { :shutdown, 0 }
  end

  defp handle_error(error, exit_code \\ 255) do
    case error do
      %{ message: message } -> IO.puts message
      e when is_binary(e)   -> IO.puts error
      _                     -> IO.inspect error
    end
    exit { :shutdown, exit_code }
  end

  defp term_dimenstions do
    {rows, _} = System.cmd "tput", ["lines"]
    {cols, _} = System.cmd "tput", ["cols"]

    [
      width: cols |> String.trim |> String.to_integer,
      height: rows |> String.trim |> String.to_integer
    ]
  end
end
