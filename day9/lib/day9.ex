defmodule Day9 do
  # Change to @input 1 for part1
  @input 2

  @doc """
  Boost keycode for advent input.

  ## Examples

      iex> Day9.boost_keycode_for_advent_input()
      {:ok, 1102}

  """
  def boost_keycode_for_advent_input() do
    input() |> boost_keycode()
  end

  @doc """
  Boost keycode.

  ## Examples

      iex> Day9.boost_keycode([109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99])
      {:ok, 109}

  """
  def boost_keycode(instructions) do
    0..length(instructions)
    |> Stream.zip(instructions)
    |> Enum.into(%{})
    |> Map.put(-1, 0)
    |> evaluate_steps(0)
    |> Map.fetch(0)
  end

  defp evaluate_steps(state, step) do
    case state[step] do
      99 ->
        state

      instruction ->
        {instruction_code, parameter_modes} = parse_instruction(instruction)

        {updated_state, updated_step} =
          execute_instruction(instruction_code, parameter_modes, state, step)

        evaluate_steps(updated_state, updated_step)
    end
  end

  defp parse_instruction(instruction) do
    reversed =
      instruction
      |> to_string()
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.map(&String.to_integer/1)

    {Enum.at(reversed, 0), Enum.drop(reversed, 2)}
  end

  defp execute_instruction(1, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)
    result_index = resolve_index(state[step + 3], Enum.at(parameter_modes, 2), state)

    {Map.put(state, result_index, argument_a + argument_b), step + 4}
  end

  defp execute_instruction(2, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)
    result_index = resolve_index(state[step + 3], Enum.at(parameter_modes, 2), state)

    {Map.put(state, result_index, argument_a * argument_b), step + 4}
  end

  defp execute_instruction(3, parameter_modes, state, step) do
    result_index = resolve_index(state[step + 1], Enum.at(parameter_modes, 0), state)
    {Map.put(state, result_index, @input), step + 2}
  end

  defp execute_instruction(4, parameter_modes, state, step) do
    result = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    IO.inspect(result)
    {state, step + 2}
  end

  defp execute_instruction(5, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)

    if argument_a != 0 do
      {state, argument_b}
    else
      {state, step + 3}
    end
  end

  defp execute_instruction(6, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)

    if argument_a == 0 do
      {state, argument_b}
    else
      {state, step + 3}
    end
  end

  defp execute_instruction(7, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)
    result_index = resolve_index(state[step + 3], Enum.at(parameter_modes, 2), state)

    if argument_a < argument_b do
      {Map.put(state, result_index, 1), step + 4}
    else
      {Map.put(state, result_index, 0), step + 4}
    end
  end

  defp execute_instruction(8, parameter_modes, state, step) do
    argument_a = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(state[step + 2], Enum.at(parameter_modes, 1), state)
    result_index = resolve_index(state[step + 3], Enum.at(parameter_modes, 2), state)

    if argument_a == argument_b do
      {Map.put(state, result_index, 1), step + 4}
    else
      {Map.put(state, result_index, 0), step + 4}
    end
  end

  defp execute_instruction(9, parameter_modes, state, step) do
    argument = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    {Map.update(state, -1, 0, &(&1 + argument)), step + 2}
  end

  defp resolve_argument(argument, nil, state) do
    state[argument] || 0
  end

  defp resolve_argument(argument, 0, state) do
    state[argument] || 0
  end

  defp resolve_argument(argument, 1, _) do
    argument
  end

  defp resolve_argument(argument, 2, state) do
    position = state[-1] + argument
    state[position] || 0
  end

  defp resolve_index(argument, nil, _) do
    argument
  end

  defp resolve_index(argument, 0, _) do
    argument
  end

  defp resolve_index(argument, 2, state) do
    argument + state[-1]
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
