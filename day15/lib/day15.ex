defmodule Day15 do
  @moduledoc """
  Documentation for Day15.
  """

  @doc """
  Number of steps to get oxygen on the ship

  ## Examples


      iex> Day15.steps_to_fill_with_air()
      278

  """
  def steps_to_fill_with_air do
    {[{{_, computer_state_at_oxygen_tank, _}, _} | _], _} =
      visit([{init_computer_state(), {0, 0}, 0}], [{0, 0}], [], 0)

    {_, steps} = visit([{computer_state_at_oxygen_tank, {0, 0}, 0}], [{0, 0}], [], 0)
    steps
  end

  @doc """
  Number of steps to reach oxygen tank

  ## Examples

      iex> Day15.steps_to_oxygen_tank()
      244

  """
  def steps_to_oxygen_tank do
    visit([{init_computer_state(), {0, 0}, 0}], [{0, 0}], [], 0)
    |> (&elem(&1, 0)).()
    |> Enum.at(-1)
    |> (&elem(&1, 1)).()
  end

  defp visit([], _, outputs, last_distance) do
    {outputs, last_distance - 1}
  end

  defp visit([{computer_state, position, bfs_distance} | rest], visited, outputs, _) do
    next_objects =
      possible_moves(computer_state, position)
      |> Enum.filter(fn {_, _, position} ->
        !Enum.member?(visited, position)
      end)

    position_of_next_steps =
      next_objects
      |> Enum.map(fn {_, _, position} -> position end)

    next_steps_with_distance =
      next_objects
      |> Enum.map(fn {_, state, position} -> {state, position, bfs_distance + 1} end)

    current_outputs =
      next_objects
      |> Enum.filter(fn {object, _, _} -> object == 2 end)
      |> Enum.map(fn x -> {x, bfs_distance + 1} end)

    visit(
      rest ++ next_steps_with_distance,
      visited ++ position_of_next_steps,
      outputs ++ current_outputs,
      bfs_distance + 1
    )
  end

  defp possible_moves(computer_state, position) do
    [1, 2, 3, 4]
    |> Enum.map(fn move -> move_robot(computer_state, position, move) end)
    |> Enum.filter(fn {output, _, _} -> output > 0 end)
  end

  defp move_robot({state, index}, position, direction) do
    {:output, _, output, updated_state, updated_step} =
      IntCodeComputer.run(state, index, [direction])

    {output, {updated_state, updated_step}, update_position(position, direction)}
  end

  defp update_position({x, y}, direction) do
    case direction do
      1 -> {x, y + 1}
      2 -> {x, y - 1}
      3 -> {x - 1, y}
      4 -> {x + 1, y}
    end
  end

  defp init_computer_state do
    initial_state =
      0..length(input())
      |> Stream.zip(input())
      |> Enum.into(%{})
      |> Map.put(-1, 0)

    {initial_state, 0}
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
