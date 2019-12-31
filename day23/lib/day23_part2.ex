defmodule Day23Part2 do
  @doc """
  ## Examples

      iex> Day23Part2.repeated_packet_to_255()
      {99289, 15678}

  """
  def repeated_packet_to_255 do
    iterate(init_memory(), init_computers(), 0)
  end

  defp iterate(memory, computers, current_computer) do
    {state_for_current, step_for_current} = Enum.at(computers, current_computer)

    {memory_with_updated_stall, memory_for_current} =
      memory_for_computer(memory, current_computer)

    case IntCodeComputer.run(state_for_current, step_for_current, memory_for_current) do
      {:output, inputs, destination, updated_state, updated_step} ->
        {updated_state, updated_step, updated_memory} =
          handle_output(destination, updated_state, updated_step, memory_with_updated_stall)

        iterate(
          List.replace_at(updated_memory, current_computer, inputs),
          List.replace_at(computers, current_computer, {updated_state, updated_step}),
          rem(current_computer + 1, 50)
        )

      {:input, [], [], updated_state, updated_step} ->
        case maybe_add_signal_from_nat(memory_with_updated_stall, current_computer) do
          {:halt, result} ->
            result

          {:continue, memory_with_signal_from_nat} ->
            iterate(
              List.replace_at(memory_with_signal_from_nat, current_computer, []),
              List.replace_at(computers, current_computer, {updated_state, updated_step}),
              rem(current_computer + 1, 50)
            )
        end
    end
  end

  defp handle_output(255, state, step, memory) do
    handle_message_to_nat(state, step, memory)
  end

  defp handle_output(destination, state, step, memory) do
    add_x_and_y_to_memory(destination, state, step, memory)
  end

  defp add_x_and_y_to_memory(destination, state, step, memory) do
    {x, y, updated_state, updated_step} = get_x_and_y(state, step)
    {updated_state, updated_step, List.update_at(memory, destination, fn q -> q ++ [x, y] end)}
  end

  defp handle_message_to_nat(state, step, memory) do
    {x, y, updated_state, updated_step} = get_x_and_y(state, step)
    {updated_state, updated_step, List.replace_at(memory, 100, {x, y})}
  end

  defp get_x_and_y(state, step) do
    {:output, _, x, updated_state, updated_step} = IntCodeComputer.run(state, step, [])

    {:output, _, y, updated_state, updated_step} =
      IntCodeComputer.run(updated_state, updated_step, [])

    {x, y, updated_state, updated_step}
  end

  defp maybe_add_signal_from_nat(memory, 49) do
    cond do
      are_all_computers_stalled?(memory) && Enum.at(memory, 100) == Enum.at(memory, 101) ->
        {:halt, Enum.at(memory, 100)}

      are_all_computers_stalled?(memory) && Enum.at(memory, 100) != Enum.at(memory, 101) ->
        updated_memory =
          memory
          |> List.replace_at(0, Tuple.to_list(Enum.at(memory, 100)))
          |> List.replace_at(101, Enum.at(memory, 100))

        {:continue, updated_memory}

      true ->
        {:continue, memory}
    end
  end

  defp maybe_add_signal_from_nat(memory, _) do
    {:continue, memory}
  end

  defp are_all_computers_stalled?(memory) do
    memory |> Enum.drop(50) |> Enum.take(50) |> Enum.all?(fn running -> !running end)
  end

  defp memory_for_computer(memory, computer) do
    case length(Enum.at(memory, computer)) do
      0 -> {List.replace_at(memory, computer + 50, false), [-1]}
      _ -> {List.replace_at(memory, computer + 50, true), Enum.at(memory, computer)}
    end
  end

  defp init_computers do
    0..49 |> Enum.map(fn _ -> {init_computer_state(), 0} end)
  end

  defp init_memory do
    computer_memory = 0..49 |> Enum.map(fn i -> [i] end)
    are_running = 0..49 |> Enum.map(fn _ -> true end)

    computer_memory ++ are_running ++ [{0, 0}] ++ [{-1, -1}]
  end

  defp init_computer_state do
    0..length(input()) |> Stream.zip(input()) |> Enum.into(%{}) |> Map.put(-1, 0)
  end

  defp input do
    File.read!("lib/input") |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
