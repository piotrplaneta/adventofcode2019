defmodule Day17 do
  @moduledoc """
  Documentation for Day17.
  """

  @doc """
  Dust collected

  ## Examples

      iex> Day17.dust_collected()
      923795

  """
  def dust_collected do
    {grid, _} = parse_init_output()

    print(grid)

    computer_input =
      [66, 44, 65, 44, 66, 44, 67, 44, 65, 44, 67, 44, 66, 44, 67, 44, 65, 44, 67, 10] ++
        [82, 44, 49, 48, 44, 76, 44, 56, 44, 76, 44, 56, 44, 76, 44, 49, 48, 10] ++
        [76, 44, 56, 44, 82, 44, 49, 48, 44, 76, 44, 49, 48, 10] ++
        [76, 44, 52, 44, 76, 44, 54, 44, 76, 44, 56, 44, 76, 44, 56, 10] ++ [110, 10]

    Stream.iterate(
      {:start, computer_input, [], init_computer_state(), 0},
      fn {_, inputs, _, state, step} ->
        IntCodeComputer.run(state, step, inputs)
      end
    )
    |> Enum.take_while(fn {instruction, _, _, _, _} ->
      instruction != :halt
    end)
    |> Enum.filter(fn {instruction, _, _, _, _} -> instruction == :output end)
    |> Enum.map(fn {_, _, output, _, _} -> output end)
    |> Enum.at(-1)
  end

  defp print(grid) do
    max_x = grid |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = grid |> Map.keys() |> Enum.map(&elem(&1, 1)) |> Enum.max()

    for y <- 0..max_y do
      for x <- 0..max_x do
        grid[{x, y}]
      end
      |> Enum.join("")
      |> IO.puts()
    end
  end

  @doc """
  Number of intersections

  ## Examples

      iex> Day17.intersection_count()
      5940

  """
  def intersection_count do
    {grid, _} = parse_init_output()

    grid
    |> Enum.filter(fn {{x, y}, value} ->
      value == "#" && grid[{x - 1, y}] == "#" && grid[{x + 1, y}] == "#" &&
        grid[{x, y - 1}] == "#" && grid[{x, y + 1}] == "#"
    end)
    |> Enum.map(fn {{x, y}, _} -> x * y end)
    |> Enum.sum()
  end

  defp parse_init_output do
    Stream.iterate({:start, [], [], init_computer_state(), 0}, fn {_, _, _, state, step} ->
      IntCodeComputer.run(state, step, [])
    end)
    |> Enum.take_while(fn {instruction, _, _, _, _} ->
      instruction == :output || instruction == :start
    end)
    |> Enum.filter(fn {instruction, _, _, _, _} -> instruction == :output end)
    |> Enum.map(fn {_, _, output, _, _} -> output end)
    |> Enum.reduce({%{}, {0, 0}}, fn elem, {grid, {x, y}} ->
      case elem do
        46 ->
          {Map.put(grid, {x, y}, "."), {x + 1, y}}

        35 ->
          {Map.put(grid, {x, y}, "#"), {x + 1, y}}

        10 ->
          {grid, {0, y + 1}}

        60 ->
          {Map.put(grid, {x, y}, "<"), {x + 1, y}}

        62 ->
          {Map.put(grid, {x, y}, ">"), {x + 1, y}}

        94 ->
          {Map.put(grid, {x, y}, "^"), {x + 1, y}}

        76 ->
          {Map.put(grid, {x, y}, "v"), {x + 1, y}}

        _ ->
          {grid, {x, y}}
      end
    end)
  end

  defp init_computer_state do
    0..length(input())
    |> Stream.zip(input())
    |> Enum.into(%{})
    |> Map.put(-1, 0)
    |> Map.put(0, 2)
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
