defmodule Day21 do
  @doc """
  ## Examples

      iex> Day21.hull_damage_with_run_mode()
      1142686742

  """
  def hull_damage_with_run_mode do
    instructions =
      "NOT A J\nNOT B T\nOR T J\nNOT C T\nOR T J\nAND D J\nNOT E T\nAND H T\nOR E T\nAND T J\nRUN\n"
      |> String.to_charlist()

    execute_computer_with_instructions(instructions)
  end

  @doc """
  ## Examples

      iex> Day21.hull_damage()
      19358262

  """
  def hull_damage do
    instructions =
      "NOT A J\nNOT B T\nOR T J\nNOT C T\nOR T J\nAND D J\nWALK\n" |> String.to_charlist()

    execute_computer_with_instructions(instructions)
  end

  defp execute_computer_with_instructions(instructions) do
    Stream.iterate(
      {:start, instructions, [], init_computer_state(), 0},
      fn {_, inputs, _, state, step} ->
        IntCodeComputer.run(state, step, inputs)
      end
    )
    |> Enum.take_while(fn {instruction, _, _, _, _} ->
      instruction != :halt
    end)
    |> Enum.filter(fn {instruction, _, _, _, _} -> instruction == :output end)
    |> Enum.map(fn {_, _, output, _, _} -> output end)
    |> Enum.at(-1)
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
