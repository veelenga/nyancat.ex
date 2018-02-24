#  Copyright (c) 2011 Ben Arblaster.  All rights reserved.
#  Copyright (c) 2011 Kevin Lange.  All rights reserved.
#  Copyright (c) 2018 Vitalii Elenhaupt. All rights reserved.
#
#  Original implementation Developed by: Kevin Lange
#                http://github.com/klange/nyancat
#  Ruby port by: Ben Arblaster
#                http://github.com/andatche/ruby_nyancat
#  Elixir port by: Vitalii Elenhaupt
#                https://github.com/veelenga/nyancat.ex
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to
#  deal with the Software without restriction, including without limitation the
#  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#  sell copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimers.
#    2. Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimers in the
#       documentation and/or other materials provided with the distribution.
#    3. Neither the names of the Association for Computing Machinery, Kevin
#       Lange, nor the names of its contributors may be used to endorse
#       or promote products derived from this Software without specific prior
#       written permission.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
#  CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
#  WITH THE SOFTWARE.
defmodule Nyancat do

  @output "  "

  defp load_assets do
    {
      YamlElixir.read_from_file("assets/frames.yml"),
      YamlElixir.read_from_file("assets/palette.yml")
    }
  end

  defp dimentions(width, height, frames) do
    first_frame = List.first(frames)
    frame_width = first_frame |> List.first |> String.length
    frame_height = first_frame |> length

    width = div width, 2 * String.length(@output)

    min_row = div (frame_height - height), 2
    min_col = div (frame_width - width), 2

    max_row = if frame_height > height, do: min_row + height, else: frame_height
    max_col = if frame_width > width, do: min_col + width, else: frame_width

    anim_width = (max_col - min_col) * String.length @output

    { min_row..max_row, min_col..max_col, anim_width }
  end

  defp colorize(codepoints, palette) do
    codepoints
    |> Enum.map(&("\e[48;5;#{Map.get palette, &1}m#{@output}"))
    |> Enum.join
    |> Kernel.<>("\e[m\n")
  end

  defp animation(frames, palette, rows, cols) do
    Enum.map frames, fn(frame) ->
      frame
      |> Enum.slice(rows)
      |> Enum.map(fn(line) ->
        line
        |> String.codepoints
        |> Enum.slice(cols)
        |> colorize(palette)
      end)
    end
  end

  defp time_line(time, width) do
    "You have nyaned for #{time} seconds!"
      |> String.pad_leading(div width, 2)
  end

  def start(options) do
    { frames, palette } = load_assets()
    { rows, cols, anim_width } = dimentions options[:width], options[:height], frames

    start_time = System.system_time(:second)

    IO.puts "\e[H\e[2J\e[?25l"

    animation(frames, palette, rows, cols)
    |> Stream.cycle
    |> Enum.each(fn(frame) ->
      IO.puts frame
      IO.puts "\e[1;37;17m"
      IO.puts time_line(System.system_time(:second) - start_time, anim_width)
      :timer.sleep(90)
      IO.puts "\e[H"
    end)
  end
end
