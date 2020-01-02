defmodule Day25 do
  @doc """

  ## Examples

      iex> Day25.password()
      "1073815584"

  """
  def password() do
    collect_all =
      "north\ntake spool of cat6\nnorth\ntake monolith\nnorth\ntake hypercube\nsouth\nsouth\nsouth\nsouth\ntake fixed point\nnorth\nnorth\neast\neast\ntake easter egg\neast\nsouth\ntake ornament\nnorth\nwest\nwest\nwest\nnorth\nwest\ntake planetoid\neast\nsouth\neast\nnorth\ntake candy cane\nsouth\neast\neast\nsouth\nwest\nsouth\n"
      |> String.to_charlist()

    {_, all_items_computer} =
      execute_computer_with_instructions(collect_all, {init_computer_state(), 0})

    drop_all =
      items()
      |> Enum.map(fn item -> "drop " <> item end)
      |> Enum.join("\n")
      |> String.to_charlist()

    {_, dropped_items_computer} =
      execute_computer_with_instructions(drop_all ++ '\n', all_items_computer)

    Regex.named_captures(
      ~r/get in by typing (?<code>\d+)/,
      try_every_combination(dropped_items_computer) |> List.to_string()
    )["code"]
  end

  defp try_every_combination(computer) do
    1..255
    |> Enum.map(fn comb ->
      Integer.to_string(comb, 2) |> String.pad_leading(8, "0") |> String.graphemes()
    end)
    |> Enum.map(fn comb ->
      comb
      |> Enum.with_index()
      |> Enum.reduce("", fn {take, index}, instruction ->
        if take == "1" do
          instruction <> "take " <> Enum.at(items(), index) <> "\n"
        else
          instruction
        end
      end)
    end)
    |> Enum.map(&String.to_charlist(&1))
    |> Enum.reduce_while(nil, fn instruction, _ ->
      execute_computer_with_instructions(instruction ++ 'west\n', computer)
    end)
  end

  defp execute_computer_with_instructions(instructions, {state, step}) do
    outputs =
      Stream.iterate(
        {:start, instructions, [], state, step},
        fn {_, inputs, _, running_state, running_step} ->
          IntCodeComputer.run(running_state, running_step, inputs)
        end
      )
      |> Enum.take_while(fn {instruction, _, _, _, _} ->
        instruction != :input && instruction != :halt
      end)
      |> Enum.filter(fn {instruction, _, _, _, _} -> instruction == :output end)

    {_, _, _, updated_state, updated_step} = Enum.at(outputs, -1)

    case IntCodeComputer.run(updated_state, updated_step, []) do
      {:halt, _, _, _, _} -> {:halt, outputs |> Enum.map(fn {_, _, output, _, _} -> output end)}
      _ -> {:cont, {updated_state, updated_step}}
    end
  end

  defp items do
    [
      "spool of cat6",
      "monolith",
      "hypercube",
      "fixed point",
      "easter egg",
      "ornament",
      "planetoid",
      "candy cane"
    ]
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
