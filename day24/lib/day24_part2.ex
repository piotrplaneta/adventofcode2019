defmodule Day24Part2 do
  @doc """

    A bug dies (becoming an empty space) unless there is exactly one bug adjacent to it.
    An empty space becomes infested with a bug if exactly one or two bugs are adjacent to it.

  ## Examples

      iex> Day24Part2.bugs_after(200)
      1983

  """
  def bugs_after(minutes) do
    init_grid() |> iterate(minutes, 0) |> bugs()
  end

  defp iterate(grid, iterations, current_iteration) do
    if current_iteration == iterations do
      grid
    else
      iterate(tick(grid, current_iteration), iterations, current_iteration + 1)
    end
  end

  defp tick(grid, current_iteration) do
    max_level = div(current_iteration + 2, 2)

    for(x <- 0..4, y <- 0..4, level <- -max_level..max_level, do: {x, y, level})
    |> Enum.reduce(%{}, fn {x, y, level}, acc ->
      if x == 2 && y == 2 do
        acc
      else
        Map.put(acc, {x, y, level}, spawn_or_kill(grid[{x, y, level}], {x, y, level}, grid))
      end
    end)
  end

  def spawn_or_kill(true, position, grid) do
    neighbours(position, grid) == 1
  end

  def spawn_or_kill(false, position, grid) do
    neighbours(position, grid) == 1 || neighbours(position, grid) == 2
  end

  def spawn_or_kill(nil, position, grid) do
    neighbours(position, grid) == 1 || neighbours(position, grid) == 2
  end

  defp neighbours({0, 0, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {1, 0}]) +
      ([grid[{2, 1, level - 1}], grid[{1, 2, level - 1}]] |> Enum.count(& &1))
  end

  defp neighbours({4, 0, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {-1, 0}]) +
      ([grid[{2, 1, level - 1}], grid[{3, 2, level - 1}]] |> Enum.count(& &1))
  end

  defp neighbours({0, 4, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, -1}, {1, 0}]) +
      ([grid[{2, 3, level - 1}], grid[{1, 2, level - 1}]] |> Enum.count(& &1))
  end

  defp neighbours({4, 4, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, -1}, {-1, 0}]) +
      ([grid[{2, 3, level - 1}], grid[{3, 2, level - 1}]] |> Enum.count(& &1))
  end

  defp neighbours({0, _, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {0, -1}, {1, 0}]) +
      if grid[{1, 2, level - 1}], do: 1, else: 0
  end

  defp neighbours({4, _, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {0, -1}, {-1, 0}]) +
      if grid[{3, 2, level - 1}], do: 1, else: 0
  end

  defp neighbours({_, 0, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {1, 0}, {-1, 0}]) +
      if grid[{2, 1, level - 1}], do: 1, else: 0
  end

  defp neighbours({_, 4, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, -1}, {1, 0}, {-1, 0}]) +
      if grid[{2, 3, level - 1}], do: 1, else: 0
  end

  defp neighbours({1, 2, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {0, -1}, {-1, 0}]) +
      Enum.count(0..4, fn y -> grid[{0, y, level + 1}] end)
  end

  defp neighbours({3, 2, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {0, -1}, {1, 0}]) +
      Enum.count(0..4, fn y -> grid[{4, y, level + 1}] end)
  end

  defp neighbours({2, 1, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, -1}, {1, 0}, {-1, 0}]) +
      Enum.count(0..4, fn x -> grid[{x, 0, level + 1}] end)
  end

  defp neighbours({2, 3, level} = position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {1, 0}, {-1, 0}]) +
      Enum.count(0..4, fn x -> grid[{x, 4, level + 1}] end)
  end

  defp neighbours(position, grid) do
    neighbours_on_the_same_level(position, grid, [{0, 1}, {0, -1}, {1, 0}, {-1, 0}])
  end

  defp neighbours_on_the_same_level({x, y, level}, grid, possible) do
    possible |> Enum.count(fn {dx, dy} -> grid[{x + dx, y + dy, level}] end)
  end

  defp bugs(grid) do
    grid |> Map.values() |> Enum.count(& &1)
  end

  defp init_grid do
    input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, grid ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {elem, x}, line_grid ->
        Map.put(line_grid, {x, y, 0}, elem == "#")
      end)
    end)
  end

  defp input do
    File.read!("lib/input")
    |> String.split("\n")
  end
end
