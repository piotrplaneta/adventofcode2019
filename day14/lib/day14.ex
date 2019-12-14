defmodule Day14 do
  @trillion 1_000_000_000_000
  @moduledoc """
  Documentation for Day14.
  """

  @doc """
  Max fuel with 1 trillion ore

  ## Examples

      iex> Day14.max_fuel(Day14.test_input())
      460664

      iex> Day14.max_fuel(Day14.advent_input())
      998536


  """
  def max_fuel(instructions) do
    recipies = parse_input(instructions)
    min = div(@trillion, required(recipies, "ORE", 1))
    max = min * 3

    binary_search_max_fuel(min, max, recipies)
  end

  defp binary_search_max_fuel(min, max, recipies) do
    middle = div(max + min, 2)

    cond do
      required(recipies, "ORE", middle) <= @trillion &&
          required(recipies, "ORE", middle + 1) > @trillion ->
        middle

      required(recipies, "ORE", middle) < @trillion ->
        binary_search_max_fuel(middle, max, recipies)

      required(recipies, "ORE", middle) > @trillion ->
        binary_search_max_fuel(min, middle, recipies)
    end
  end

  @doc """
  Ore required for 1 fuel

  ## Examples

      iex> Day14.ore_for_one_fuel(Day14.test_input())
      2210736

      iex> Day14.ore_for_one_fuel(Day14.advent_input())
      2486514

  """
  def ore_for_one_fuel(instructions) do
    parse_input(instructions)
    |> required("ORE", 1)
  end

  defp required(_, "FUEL", fuel_quantity) do
    fuel_quantity
  end

  defp required(recipies, element, fuel_quantity) do
    recipies[element]
    |> Enum.map(fn {target_name, target_proportion} ->
      required(recipies, target_name, fuel_quantity) |> required_reactions(target_proportion)
    end)
    |> Enum.sum()
  end

  defp required_reactions(quantity, proportions) do
    div(
      next_divisable(quantity, elem(proportions, 1)) * elem(proportions, 0),
      elem(proportions, 1)
    )
  end

  defp next_divisable(n, m) do
    case rem(n, m) do
      0 -> n
      other -> n + m - other
    end
  end

  defp parse_input(instructions) do
    instructions
    |> Enum.map(&String.split(&1, " => "))
    |> Enum.reduce(%{}, fn line, recipies ->
      target = Enum.at(line, -1) |> parse_element()
      sources = Enum.at(line, 0) |> String.split(", ") |> Enum.map(&parse_element/1)

      sources
      |> Enum.reduce(recipies, fn source, recipies ->
        Map.update(
          recipies,
          elem(source, 0),
          [{elem(target, 0), {elem(source, 1), elem(target, 1)}}],
          fn e_sources ->
            e_sources ++ [{elem(target, 0), {elem(source, 1), elem(target, 1)}}]
          end
        )
      end)
    end)
  end

  defp parse_element(element) do
    [quantity | [name | _]] = element |> String.split(" ")

    {name, String.to_integer(quantity)}
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
