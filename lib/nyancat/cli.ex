defmodule Nyancat.Cli do
  def main(_argv) do
    Process.flag(:trap_exit, true)

    {w, h} = term_dimenstions()
    options = %{width: w, height: h}
    Nyancat.start(options)
  catch
    e -> IO.inspect e
  end

  defp term_dimenstions do
    {rows, _} = System.cmd "tput", ["lines"]
    {cols, _} = System.cmd "tput", ["cols"]

    {
      cols |> String.trim |> String.to_integer,
      rows |> String.trim |> String.to_integer
    }
  end
end
