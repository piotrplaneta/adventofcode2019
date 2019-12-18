defmodule Day18 do
  @moduledoc """
  Documentation for Day18.
  """

  @doc """
  Steps to get all keys in a multi robot env

  ## Examples

      iex> Day18.steps_with_multiple_robots(Day18.advent_input_part2(), 80, 80)
      72

  """
  def steps_with_multiple_robots(input, max_x, max_y) do
    big_maze = parse_input(input)

    maze_a =
      big_maze
      |> Enum.filter(fn {{x, y}, _} -> x <= div(max_x, 2) && y <= div(max_y, 2) end)

    maze_b =
      big_maze
      |> Enum.filter(fn {{x, y}, _} -> x >= div(max_x, 2) && y <= div(max_y, 2) end)

    maze_c =
      big_maze
      |> Enum.filter(fn {{x, y}, _} -> x <= div(max_x, 2) && y >= div(max_y, 2) end)

    maze_d =
      big_maze
      |> Enum.filter(fn {{x, y}, _} -> x >= div(max_x, 2) && y >= div(max_y, 2) end)

    [maze_a, maze_b, maze_c, maze_d]
    |> Enum.map(&Enum.into(&1, %{}))
    |> Enum.map(&remove_doors_from_different_mazes/1)
    |> Enum.map(&steps/1)
    |> Enum.sum()
  end

  defp remove_doors_from_different_mazes(maze) do
    maze
    |> Enum.reduce(maze, fn {position, elem}, acc ->
      case elem =~ ~r([A-Z]) do
        true ->
          if Enum.any?(acc, fn {_, other_elem} ->
               other_elem =~ ~r([a-z]) && elem == String.upcase(other_elem)
             end) do
            acc
          else
            Map.put(acc, position, ".")
          end

        false ->
          acc
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Steps to get all keys

  ## Examples

      iex> Day18.test_input() |> Day18.parse_input() |> Day18.steps()
      136

  """
  def steps(maze) do
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

  def parse_input(input) do
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

  def advent_input_part2 do
    File.read!("lib/advent_input_part2")
    |> String.split("\n")
  end
end
