defmodule Day18 do
  @moduledoc """
  Documentation for Day18.
  """

  @doc """
  Steps to get all keys in a multi robot env

  ## Examples

      iex> Day18.steps_with_multiple_robots(Day18.test_input_part2())
      72

  """
  def steps_with_multiple_robots(input) do
    maze = parse_input(input)

    robot_positions =
      maze
      |> Enum.filter(fn {_, val} -> val == "@" end)
      |> Enum.map(&elem(&1, 0))

    key_length =
      maze
      |> Enum.filter(fn {_, v} -> v =~ ~r([a-z]) end)
      |> length()

    visit_with_multirobots(
      elem(init_starting_queue_and_visited(robot_positions), 0),
      maze,
      elem(init_starting_queue_and_visited(robot_positions), 1),
      key_length
    )
  end

  defp visit_with_multirobots(queue, maze, visited, key_length) do
    {{:value, {position, other_positions, keys, step}}, queue} = :queue.out(queue)
    updated_keys = maybe_add_key(keys, maze[position])

    if MapSet.size(updated_keys) == key_length do
      step
    else
      next_positions =
        possible_moves(position, updated_keys, maze)
        |> Enum.filter(&(!MapSet.member?(visited, {&1, other_positions, updated_keys})))
        |> Enum.map(fn pos -> {pos, other_positions, updated_keys} end)

      next_position_with_steps =
        next_positions
        |> Enum.map(fn {position, other_positions, keys} ->
          {position, other_positions, keys, step + 1}
        end)

      queue =
        next_position_with_steps
        |> Enum.reduce(queue, fn x, acc ->
          :queue.in(x, acc)
        end)

      # If keys modified, update queue and visited with all robots with new keys
      visit(queue, maze, MapSet.union(visited, MapSet.new(next_positions)), key_length)
    end
  end

  defp init_starting_queue_and_visited(robot_positions) do
    robot_with_other_robots_and_keys =
      Enum.map(robot_positions, &{&1, Enum.sort(robot_positions -- [&1]), MapSet.new()})

    queue =
      robot_with_other_robots_and_keys
      |> Enum.map(fn {robot_pos, other_robot_positions, keys} ->
        {robot_pos, other_robot_positions, keys, 0}
      end)
      |> :queue.from_list()

    {queue, MapSet.new(robot_with_other_robots_and_keys)}
  end

  @doc """
  Steps to get all keys

  ## Examples

      iex> Day18.steps(Day18.test_input())
      136


  """
  def steps(input) do
    maze = parse_input(input)

    robot_position =
      maze
      |> Enum.find(fn {_, val} -> val == "@" end)
      |> elem(0)

    key_length =
      maze
      |> Enum.filter(fn {_, v} -> v =~ ~r([a-z]) end)
      |> length()

    visit(
      :queue.from_list([{robot_position, MapSet.new(), 0}]),
      maze,
      MapSet.new([{robot_position, MapSet.new()}]),
      key_length
    )
  end

  defp visit([], _, _, _) do
    :infinity
  end

  defp visit(queue, maze, visited, key_length) do
    {{:value, {position, keys, step}}, queue} = :queue.out(queue)
    updated_keys = maybe_add_key(keys, maze[position])

    if MapSet.size(updated_keys) == key_length do
      step
    else
      next_positions =
        possible_moves(position, updated_keys, maze)
        |> Enum.filter(&(!MapSet.member?(visited, {&1, updated_keys})))
        |> Enum.map(fn pos -> {pos, updated_keys} end)

      next_position_with_steps =
        next_positions
        |> Enum.map(fn {position, keys} -> {position, keys, step + 1} end)

      queue =
        next_position_with_steps
        |> Enum.reduce(queue, fn x, acc ->
          :queue.in(x, acc)
        end)

      visit(queue, maze, MapSet.union(visited, MapSet.new(next_positions)), key_length)
    end
  end

  defp maybe_add_key(keys, maybe_key) do
    case maybe_key =~ ~r([a-z]) do
      true ->
        MapSet.put(keys, String.upcase(maybe_key))

      false ->
        keys
    end
  end

  defp possible_moves({x, y}, keys, maze) do
    [{x + 1, y}, {x, y - 1}, {x - 1, y}, {x, y + 1}]
    |> Enum.filter(fn new_position ->
      Map.has_key?(maze, new_position) &&
        case maze[new_position] do
          "#" ->
            false

          "." ->
            true

          "@" ->
            true

          letter ->
            case(letter == String.upcase(letter)) do
              true ->
                Enum.any?(keys, &(&1 == letter))

              false ->
                true
            end
        end
    end)
  end

  defp parse_input(input) do
    {maze, _} =
      input
      |> Enum.reduce({%{}, 0}, fn line, {acc, y} ->
        {updated_acc, _} =
          Enum.reduce(String.graphemes(line), {acc, 0}, fn elem, {line_acc, x} ->
            {Map.put(line_acc, {x, y}, elem), x + 1}
          end)

        {updated_acc, y + 1}
      end)

    maze
  end

  def test_input do
    File.read!("lib/test_input")
    |> String.split("\n")
  end

  def test_input_part2 do
    File.read!("lib/test_input_part2")
    |> String.split("\n")
  end

  def advent_input do
    File.read!("lib/advent_input")
    |> String.split("\n")
  end
end
