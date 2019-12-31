defmodule Day23 do
  @doc """
  ## Examples

      iex> Day23.packet_to_255()
      {99289, 22829}

  """
  def packet_to_255 do
    iterate(init_memory(), init_computers(), 0)
  end

  defp iterate(memory, computers, current_computer) do
    {state, step} = Enum.at(computers, current_computer)

    case IntCodeComputer.run(state, step, memory_for_computer(memory, current_computer)) do
      {:output, inputs, destination, updated_state, updated_step} ->
        if destination == 255 do
          handle_message_to_nat(updated_state, updated_step)
        else
          {updated_state, updated_step, updated_memory} =
            handle_output(destination, updated_state, updated_step, memory)

          iterate(
            List.replace_at(updated_memory, current_computer, inputs),
            List.replace_at(computers, current_computer, {updated_state, updated_step}),
            rem(current_computer + 1, 50)
          )
        end

      {:input, [], [], updated_state, updated_step} ->
        iterate(
          List.replace_at(memory, current_computer, []),
          List.replace_at(computers, current_computer, {updated_state, updated_step}),
          rem(current_computer + 1, 50)
        )
    end
  end

  defp handle_output(destination, state, step, memory) do
    {x, y, updated_state, updated_step} = get_x_and_y(state, step)
    {updated_state, updated_step, List.update_at(memory, destination, fn q -> q ++ [x, y] end)}
  end

  defp handle_message_to_nat(state, step) do
    {x, y, _, _} = get_x_and_y(state, step)
    {x, y}
  end

  defp get_x_and_y(state, step) do
    {:output, _, x, updated_state, updated_step} = IntCodeComputer.run(state, step, [])

    {:output, _, y, updated_state, updated_step} =
      IntCodeComputer.run(updated_state, updated_step, [])

    {x, y, updated_state, updated_step}
  end

  defp memory_for_computer(memory, computer) do
    case length(Enum.at(memory, computer)) do
      0 -> [-1]
      _ -> Enum.at(memory, computer)
    end
  end

  defp init_computers do
    0..49
    |> Enum.map(fn _ -> {init_computer_state(), 0} end)
  end

  defp init_memory do
    0..49
    |> Enum.map(fn i -> [i] end)
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
