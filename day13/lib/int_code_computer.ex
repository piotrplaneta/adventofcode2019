defmodule IntCodeComputer do
  def run(state, step, inputs) do
    case state[step] do
      99 ->
        {:halt, [], [], state, step}

      instruction ->
        {instruction_code, parameter_modes} = parse_instruction(instruction)

        case instruction_code do
          4 ->
            {output, updated_state, updated_step} =
              execute_instruction(4, parameter_modes, state, step)

            {:output, [], output, updated_state, updated_step}

          3 ->
            if length(inputs) == 0 do
              {:input, [], [], state, step}
            else
              {updated_state, updated_step, updated_inputs} =
                execute_instruction(3, parameter_modes, state, step, inputs)

              run(updated_state, updated_step, updated_inputs)
            end

          _ ->
            {updated_state, updated_step} =
              execute_instruction(instruction_code, parameter_modes, state, step)

            run(updated_state, updated_step, inputs)
        end
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

  defp execute_instruction(3, parameter_modes, state, step, [input | rest]) do
    result_index = resolve_index(state[step + 1], Enum.at(parameter_modes, 0), state)
    {Map.put(state, result_index, input), step + 2, rest}
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

  defp execute_instruction(4, parameter_modes, state, step) do
    result = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)
    {result, state, step + 2}
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
end
