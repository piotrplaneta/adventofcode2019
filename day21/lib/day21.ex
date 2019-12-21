defmodule Day21 do
  @doc """
  ## Examples

      iex> Day21.hull_damage()
      221

  """
  def hull_damage do
    instruction =
      "NOT A J\nNOT B T\nOR T J\nNOT C T\nOR T J\nAND D J\nWALK\n" |> String.to_charlist()

    Stream.iterate(
      {:start, instruction, [], init_computer_state(), 0},
      fn {_, inputs, _, state, step} ->
        IntCodeComputer.run(state, step, inputs)
      end
    )
    |> Enum.take_while(fn {instruction, _, _, _, _} ->
      instruction != :halt
    end)
    |> Enum.filter(fn {instruction, _, _, _, _} -> instruction == :output end)
    |> Enum.map(fn {_, _, output, _, _} -> output end)
    |> IO.puts()
  end

  defp init_computer_state do
    0..length(input())
    |> Stream.zip(input())
    |> Enum.into(%{})
    |> Map.put(-1, 0)
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
