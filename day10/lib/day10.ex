defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  @doc """
  200th destroyed asteroid

  ## Examples

      iex> Day10.lucky_asteroid(Day10.test_input())
      {8, 2}

  """
  def lucky_asteroid(space_input) do
    asteroids =
      space_input
      |> generate_space()
      |> asteroids_in_space()

    asteroids
    |> Enum.max_by(&visible_point_count(&1, asteroids))
    |> destroy_200_asteroids(asteroids)
  end

  defp destroy_200_asteroids({from, _}, asteroids) do
    asteroids
    |> Enum.filter(fn {coordinate, _} ->
      no_points_in_between?(from, coordinate, asteroids)
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.filter(&(from != &1))
    |> Enum.sort_by(&angle(from, &1))
    |> Enum.at(199)
  end

  defp angle(from, to) do
    atan = :math.atan2(elem(from, 1) - elem(to, 1), elem(to, 0) - elem(from, 0))
    atan |> normalize_angle() |> shift_by_90_degrees()
  end

  defp normalize_angle(angle) do
    if(angle <= 0) do
      -angle
    else
      2 * :math.pi() - angle
    end
  end

  defp shift_by_90_degrees(angle) do
    if angle >= 3 / 2 * :math.pi() && angle < 2 * :math.pi() do
      angle - 2 * :math.pi()
    else
      angle
    end
  end

  @doc """
  Visible asteroids

  ## Examples

      iex> Day10.visible_asteroids(Day10.test_input())
      211

  """
  def visible_asteroids(space_input) do
    asteroids =
      space_input
      |> generate_space()
      |> asteroids_in_space()

    asteroids |> Enum.map(&visible_point_count(&1, asteroids)) |> Enum.max()
  end

  defp visible_point_count({starting_point, _}, asteroids) do
    asteroids
    |> Enum.count(fn {coordinate, _} ->
      no_points_in_between?(starting_point, coordinate, asteroids)
    end)
  end

  defp no_points_in_between?(from, coordinate, asteroids) do
    Enum.count(asteroids, fn {point_in_the_middle, _} ->
      in_the_middle?(point_in_the_middle, from, coordinate) &&
        coolinear?(from, point_in_the_middle, coordinate)
    end) == 0
  end

  defp in_the_middle?(middle, starting, ending) do
    {min_x, max_x} = Enum.min_max([elem(starting, 0), elem(ending, 0)])
    {min_y, max_y} = Enum.min_max([elem(starting, 1), elem(ending, 1)])

    starting != ending && middle != starting && middle != ending && elem(middle, 0) >= min_x &&
      elem(middle, 0) <= max_x && elem(middle, 1) >= min_y && elem(middle, 1) <= max_y
  end

  def coolinear?(starting, middle, ending) do
    elem(starting, 0) * (elem(middle, 1) - elem(ending, 1)) +
      elem(middle, 0) * (elem(ending, 1) - elem(starting, 1)) +
      elem(ending, 0) * (elem(starting, 1) - elem(middle, 1)) == 0
  end

  defp asteroids_in_space(space) do
    space
    |> Enum.filter(fn {_, object} -> object == 1 end)
    |> Enum.into(%{})
  end

  defp generate_space(space_input) do
    space_input
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, current_line_space ->
      line
      |> Enum.with_index()
      |> Enum.reduce(current_line_space, fn {object, x}, current_point_space ->
        case object do
          "#" -> Map.put(current_point_space, {x, y}, 1)
          "." -> current_point_space
        end
      end)
    end)
  end

  def advent_input do
    File.read!("lib/advent_input")
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  def test_input do
    File.read!("lib/test_input")
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end
end
