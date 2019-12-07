defmodule Day7 do
  @moduledoc """
  Documentation for Day7.
  """

  @doc """
    Highest thrusters signal with feedback loop for advent input

    ## Examples

        iex> Day7.highest_thrusters_signal_with_feedback_loop_for_advent_input()
        19384820
  """
  def highest_thrusters_signal_with_feedback_loop_for_advent_input() do
    input() |> highest_thrusters_signal_with_feedback_loop()
  end

  @doc """
    Highest thrusters signal with feedback loop

    ## Examples

        iex> Day7.highest_thrusters_signal_with_feedback_loop([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
        139629729
  """
  def highest_thrusters_signal_with_feedback_loop(instructions) do
    Enum.max_by(
      permutations([5, 6, 7, 8, 9]),
      &evaluate_permutation_with_feedback_loop(&1, instructions)
    )
    |> evaluate_permutation_with_feedback_loop(instructions)
  end

  defp evaluate_permutation_with_feedback_loop([a | [b | [c | [d | [e | _]]]]], instructions) do
    computers = [
      {[a, 0], [], instructions, 0},
      {[b], [], instructions, 0},
      {[c], [], instructions, 0},
      {[d], [], instructions, 0},
      {[e], [], instructions, 0}
    ]

    evaluate_computers_in_loop(computers, 0)
  end

  defp evaluate_computers_in_loop(computers, current_computer_index) do
    {inputs, outputs, state, step} = Enum.at(computers, current_computer_index)

    step_result = evaluate_steps_with_immediate_result(inputs, outputs, state, step)

    case step_result do
      {:halt, _} ->
        computers |> Enum.at(-1) |> elem(1) |> Enum.at(0)

      {updated_state, updated_step, updated_outputs} ->
        next_computer_index = rem(current_computer_index + 1, 5)

        updated_computers =
          computers
          |> List.update_at(current_computer_index, fn _ ->
            {[], updated_outputs, updated_state, updated_step}
          end)
          |> List.update_at(next_computer_index, fn {inputs, outputs, state, index} ->
            {inputs ++ Enum.take(updated_outputs, 1), outputs, state, index}
          end)

        evaluate_computers_in_loop(updated_computers, next_computer_index)
    end
  end

  @doc """
    Highest thrusters signal for advent input

    ## Examples

        iex> Day7.highest_thrusters_signal_for_advent_input()
        17790
  """
  def highest_thrusters_signal_for_advent_input() do
    input() |> highest_thrusters_signal()
  end

  @doc """
    Highest thrusters signal

    ## Examples

        iex> Day7.highest_thrusters_signal([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0])
        65210
  """
  def highest_thrusters_signal(instructions) do
    Enum.max_by(permutations([0, 1, 2, 3, 4]), &evaluate_permutation(&1, instructions))
    |> evaluate_permutation(instructions)
  end

  defp evaluate_permutation(permutation, instructions) do
    permutation
    |> Enum.reduce(0, fn phase, input ->
      evaluate_steps([phase, input], [], instructions, 0)
      |> Enum.at(0)
    end)
  end

  defp evaluate_steps_with_immediate_result(inputs, outputs, state, step) do
    case Enum.at(state, step) do
      99 ->
        {:halt, outputs}

      4 ->
        updated_outputs = [Enum.at(state, Enum.at(state, step + 1)) | outputs]
        {state, step + 2, updated_outputs}

      instruction ->
        {instruction_code, parameter_modes} = parse_instruction(instruction)

        {updated_state, updated_step, updated_inputs, updated_outputs} =
          execute_instruction(instruction_code, parameter_modes, state, step, inputs, outputs)

        evaluate_steps_with_immediate_result(
          updated_inputs,
          updated_outputs,
          updated_state,
          updated_step
        )
    end
  end

  defp evaluate_steps(inputs, outputs, state, step) do
    case Enum.at(state, step) do
      99 ->
        outputs

      instruction ->
        {instruction_code, parameter_modes} = parse_instruction(instruction)

        {updated_state, updated_step, updated_inputs, updated_outputs} =
          execute_instruction(instruction_code, parameter_modes, state, step, inputs, outputs)

        evaluate_steps(updated_inputs, updated_outputs, updated_state, updated_step)
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

  defp execute_instruction(1, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)
    {List.replace_at(state, result_index, argument_a + argument_b), step + 4, inputs, outputs}
  end

  defp execute_instruction(2, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)
    {List.replace_at(state, result_index, argument_a * argument_b), step + 4, inputs, outputs}
  end

  defp execute_instruction(3, _, state, step, [input | rest], outputs) do
    result_index = Enum.at(state, step + 1)
    {List.replace_at(state, result_index, input), step + 2, rest, outputs}
  end

  defp execute_instruction(4, _, state, step, inputs, outputs) do
    updated_outputs = [Enum.at(state, Enum.at(state, step + 1)) | outputs]
    {state, step + 2, inputs, updated_outputs}
  end

  defp execute_instruction(5, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)

    if argument_a != 0 do
      {state, argument_b, inputs, outputs}
    else
      {state, step + 3, inputs, outputs}
    end
  end

  defp execute_instruction(6, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)

    if argument_a == 0 do
      {state, argument_b, inputs, outputs}
    else
      {state, step + 3, inputs, outputs}
    end
  end

  defp execute_instruction(7, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)

    if argument_a < argument_b do
      {List.replace_at(state, result_index, 1), step + 4, inputs, outputs}
    else
      {List.replace_at(state, result_index, 0), step + 4, inputs, outputs}
    end
  end

  defp execute_instruction(8, parameter_modes, state, step, inputs, outputs) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)

    if argument_a == argument_b do
      {List.replace_at(state, result_index, 1), step + 4, inputs, outputs}
    else
      {List.replace_at(state, result_index, 0), step + 4, inputs, outputs}
    end
  end

  defp resolve_argument(argument, nil, state) do
    Enum.at(state, argument)
  end

  defp resolve_argument(argument, 0, state) do
    Enum.at(state, argument)
  end

  defp resolve_argument(argument, 1, _) do
    argument
  end

  defp permutations([]), do: [[]]

  defp permutations(list) do
    for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
