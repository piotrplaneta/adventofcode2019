defmodule Day20Part2 do
  @doc """
  Step count.

  ## Examples

      iex> Day20Part2.test_input() |> Day20Part2.step_count()
      396

      iex> Day20Part2.advent_input() |> Day20Part2.step_count()
      5652

  """
  def step_count(input) do
    maze = parse_input(input) |> parse_teleports()
    teleports = find_teleports(maze)

    maze = update_teleports_in_maze(maze, teleports)

    robot_position =
      maze
      |> Enum.find(fn {_, val} -> val == :start end)
      |> elem(0)

    visit(
      :queue.from_list([{robot_position, 0, 0}]),
      MapSet.new([robot_position, 0]),
      maze
    )
  end

  defp visit([], _, _), do: :infinity

  defp visit(queue, visited, maze) do
    {{:value, {position, level, step}}, queue} = :queue.out(queue)

    if maze[position] == :end do
      step
    else
      possible_next_positions_with_level_and_delta =
        next_positions(maze, position, level)
        |> Enum.filter(fn {position, level, _} -> !MapSet.member?(visited, {position, level}) end)

      next_position_with_steps =
        possible_next_positions_with_level_and_delta
        |> Enum.map(fn {position, level, delta} -> {position, level, step + delta} end)

      queue =
        next_position_with_steps
        |> Enum.reduce(queue, fn x, acc ->
          :queue.in(x, acc)
        end)

      new_visited =
        possible_next_positions_with_level_and_delta
        |> Enum.map(fn {position, level, _} -> {position, level} end)

      visit(queue, MapSet.union(visited, MapSet.new(new_visited)), maze)
    end
  end

  defp next_positions(maze, position, level) do
    case maze[position] do
      {:teleport, :internal, destination} ->
        next_direct_positions(maze, destination, level + 1, true)

      {:teleport, :external, destination} ->
        next_direct_positions(maze, destination, level - 1, true)

      _ ->
        next_direct_positions(maze, position, level, false)
    end
  end

  defp next_direct_positions(maze, {x, y}, new_level, was_teleport_used) do
    [{x + 1, y}, {x, y - 1}, {x - 1, y}, {x, y + 1}]
    |> Enum.filter(fn new_position -> Map.has_key?(maze, new_position) end)
    |> Enum.filter(fn new_position ->
      case maze[new_position] do
        "." -> true
        :end -> new_level == 0
        {:teleport, :internal, _} -> true
        {:teleport, :external, _} -> new_level != 0
        _ -> false
      end
    end)
    |> Enum.map(fn next_position ->
      if was_teleport_used do
        {next_position, new_level, 2}
      else
        {next_position, new_level, 1}
      end
    end)
  end

  defp update_teleports_in_maze(maze, teleports) do
    maze
    |> Enum.reduce(maze, fn {coord, maybe_teleport}, acc ->
      cond do
        maybe_teleport == "AA" ->
          Map.put(acc, coord, :start)

        maybe_teleport == "ZZ" ->
          Map.put(acc, coord, :end)

        maybe_teleport =~ ~r([A-Z]{2}) ->
          update_with_other_side_of_teleport(acc, teleports, maybe_teleport, coord)

        true ->
          acc
      end
    end)
  end

  defp update_with_other_side_of_teleport(maze, teleports, teleport, coord) do
    other_coord =
      teleports[teleport]
      |> Enum.find(fn other_coord -> other_coord != coord end)

    Map.put(maze, coord, {:teleport, internal_or_external(maze, coord), other_coord})
  end

  defp internal_or_external(maze, {x, y}) do
    max_x = maze |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = maze |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    if x == 2 || x == max_x - 2 || y == 2 || y == max_y - 2 do
      :external
    else
      :internal
    end
  end

  defp find_teleports(maze) do
    maze
    |> Enum.reduce(%{}, fn {coord, maybe_teleport}, acc ->
      case maybe_teleport =~ ~r([A-Z]{2}) do
        true ->
          Map.update(acc, maybe_teleport, [coord], fn teleport_coordinates ->
            [coord | teleport_coordinates]
          end)

        false ->
          acc
      end
    end)
  end

  defp parse_teleports(maze) do
    maze
    |> Enum.reduce(maze, fn {{x, y}, _}, acc ->
      cond do
        Map.has_key?(acc, {x + 1, y}) && maze[{x, y}] =~ ~r([A-Z]) &&
            maze[{x + 1, y}] =~ ~r([A-Z]) ->
          update_teleport_in_maze(acc, {x, y}, {x + 1, y})

        Map.has_key?(acc, {x, y + 1}) && maze[{x, y}] =~ ~r([A-Z]) &&
            maze[{x, y + 1}] =~ ~r([A-Z]) ->
          update_teleport_in_maze(acc, {x, y}, {x, y + 1})

        true ->
          acc
      end
    end)
  end

  defp update_teleport_in_maze(maze, {x_a, y_a} = point_a, {x_b, y_b} = point_b) do
    name = maze[point_a] <> maze[point_b]

    case x_a == x_b do
      true ->
        [{x_a, y_a - 1}, {x_a, y_b + 1}]
        |> Enum.find(fn coord -> maze[coord] == "." end)
        |> (fn coord -> Map.put(maze, coord, name) end).()

      false ->
        [{x_a - 1, y_a}, {x_b + 1, y_a}]
        |> Enum.find(fn coord -> maze[coord] == "." end)
        |> (fn coord -> Map.put(maze, coord, name) end).()
    end
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

  def advent_input do
    File.read!("lib/advent_input")
    |> String.split("\n")
  end
end
