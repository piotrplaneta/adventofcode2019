defmodule Day24 do
  @doc """

    A bug dies (becoming an empty space) unless there is exactly one bug adjacent to it.
    An empty space becomes infested with a bug if exactly one or two bugs are adjacent to it.

  ## Examples

      iex> Day24.first_repeated_biodiversity()
      20751345

  """
  def first_repeated_biodiversity do
    init_grid() |> iterate(MapSet.new())
  end

  defp iterate(grid, seen) do
    current_biodiversity = biodiversity(grid)

    if MapSet.member?(seen, current_biodiversity) do
      current_biodiversity
    else
      iterate(tick(grid), MapSet.put(seen, current_biodiversity))
    end
  end

  defp tick(grid) do
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(%{}, fn {x, y}, acc ->
      Map.put(acc, {x, y}, spawn_or_kill(grid[{x, y}], {x, y}, grid))
    end)
  end

  def spawn_or_kill(true, position, grid) do
    neighbours(position, grid) == 1
  end

  def spawn_or_kill(false, position, grid) do
    neighbours(position, grid) == 1 || neighbours(position, grid) == 2
  end

  defp neighbours({x, y}, grid) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}] |> Enum.count(fn {dx, dy} -> grid[{x + dx, y + dy}] end)
  end

  defp biodiversity(grid) do
    for(x <- 0..4, y <- 0..4, do: {x, y})
    |> Enum.reduce(0, fn {x, y}, acc ->
      if grid[{x, y}] do
        acc + pow(2, 5 * y + x)
      else
        acc
      end
    end)
  end

  defp pow(n, m) do
    :math.pow(n, m) |> round()
  end

  defp init_grid do
    input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, grid ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.reduce(grid, fn {elem, x}, line_grid ->
        Map.put(line_grid, {x, y}, elem == "#")
      end)
    end)
  end

  defp input do
    File.read!("lib/input")
    |> String.split("\n")
  end
end
