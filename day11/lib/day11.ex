defmodule Day11 do
  @area_index -2
  @output_mode_index -3
  @moduledoc """
  Documentation for Day11.
  """

  @doc """
  Painted panels

  ## Examples

      iex> Day11.white_panels()
      91

  """
  def white_panels() do
    0..length(input())
    |> Stream.zip(input())
    |> Enum.into(%{})
    |> Map.put(-1, 0)
    |> Map.put(@area_index, {%{{0, 0} => "#"}, {0, 0}, {0, 1}})
    |> Map.put(@output_mode_index, 0)
    |> evaluate_steps(0)
    |> Map.get(@area_index)
    |> elem(0)
    |> Enum.filter(fn {_, color} -> color == "#" end)
    |> Enum.map(fn {{x, y}, _} -> [x, y + 5] end)
    |> length()
  end

  @doc """
  How many panels were painted

  ## Examples

      iex> Day11.painted_panel_count()
      2141

  """
  def painted_panel_count() do
    0..length(input())
    |> Stream.zip(input())
    |> Enum.into(%{})
    |> Map.put(-1, 0)
    |> Map.put(@area_index, {%{}, {0, 0}, {0, 1}})
    |> Map.put(@output_mode_index, 0)
    |> evaluate_steps(0)
    |> Map.get(@area_index)
    |> elem(0)
    |> Map.keys()
    |> length()
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

    if elem(state[@area_index], 0)[elem(state[@area_index], 1)] == "#" do
      {Map.put(state, result_index, 1), step + 2}
    else
      {Map.put(state, result_index, 0), step + 2}
    end
  end

  defp execute_instruction(4, parameter_modes, state, step) do
    result = resolve_argument(state[step + 1], Enum.at(parameter_modes, 0), state)

    case state[@output_mode_index] do
      0 ->
        updated_state = paint_area(state, result) |> Map.put(@output_mode_index, 1)

        {updated_state, step + 2}

      1 ->
        updated_state = move_robot(state, result) |> Map.put(@output_mode_index, 0)

        {updated_state, step + 2}
    end
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

  defp paint_area(state, result) do
    case result do
      0 ->
        Map.put(state, @area_index, painted_area(state, "."))

      1 ->
        Map.put(state, @area_index, painted_area(state, "#"))
    end
  end

  defp painted_area(state, color) do
    {
      Map.put(elem(state[@area_index], 0), elem(state[@area_index], 1), color),
      elem(state[@area_index], 1),
      elem(state[@area_index], 2)
    }
  end

  defp move_robot(state, result) do
    case result do
      0 ->
        process_move(state, [{0, 1}, {-1, 0}, {0, -1}, {1, 0}])

      1 ->
        process_move(state, [{0, 1}, {1, 0}, {0, -1}, {-1, 0}])
    end
  end

  defp process_move(state, rotations) do
    current_direction_index = rotations |> Enum.find_index(&(&1 == elem(state[@area_index], 2)))
    next_direction = Enum.at(rotations, rem(current_direction_index + 1, 4))

    {area, position, _} = state[@area_index]
    Map.put(state, @area_index, {area, make_step(position, next_direction), next_direction})
  end

  defp make_step({x, y}, {dx, dy}) do
    {x + dx, y + dy}
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
