defmodule Day5 do
  @input 5
  # Change to @input 1 for part 1

  @moduledoc """
  Documentation for Day5.
  """

  @doc """
  Diagnostic code.

  ## Examples

      iex> Day5.diagnostic_code()
      314

  """
  def diagnostic_code() do
    Enum.at(evaluate_steps(input(), 0), 0)
  end

  defp evaluate_steps(state, step) do
    case Enum.at(state, step) do
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
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)
    {List.replace_at(state, result_index, argument_a + argument_b), step + 4}
  end

  defp execute_instruction(2, parameter_modes, state, step) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)
    {List.replace_at(state, result_index, argument_a * argument_b), step + 4}
  end

  defp execute_instruction(3, _, state, step) do
    result_index = Enum.at(state, step + 1)
    {List.replace_at(state, result_index, @input), step + 2}
  end

  defp execute_instruction(4, _, state, step) do
    IO.inspect(Enum.at(state, Enum.at(state, step + 1)))
    {state, step + 2}
  end

  defp execute_instruction(5, parameter_modes, state, step) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)

    if argument_a != 0 do
      {state, argument_b}
    else
      {state, step + 3}
    end
  end

  defp execute_instruction(6, parameter_modes, state, step) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)

    if argument_a == 0 do
      {state, argument_b}
    else
      {state, step + 3}
    end
  end

  defp execute_instruction(7, parameter_modes, state, step) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)

    if argument_a < argument_b do
      {List.replace_at(state, result_index, 1), step + 4}
    else
      {List.replace_at(state, result_index, 0), step + 4}
    end
  end

  defp execute_instruction(8, parameter_modes, state, step) do
    argument_a = resolve_argument(Enum.at(state, step + 1), Enum.at(parameter_modes, 0), state)
    argument_b = resolve_argument(Enum.at(state, step + 2), Enum.at(parameter_modes, 1), state)
    result_index = Enum.at(state, step + 3)

    if argument_a == argument_b do
      {List.replace_at(state, result_index, 1), step + 4}
    else
      {List.replace_at(state, result_index, 0), step + 4}
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

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
