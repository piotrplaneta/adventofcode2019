defmodule Day3 do
  @moduledoc """
  Documentation for Day3.
  """

  @doc """
  Steps to the closest by steps intersection

  ## Examples

      iex> Day3.steps_to_closest_intersection_by_steps("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83")
      610

  """
  def steps_to_closest_intersection_by_steps(wire_a, wire_b) do
    wire_a_position = generate_wire_position(%{}, {0, 0}, parse_wire(wire_a), 1)
    wire_b_position = generate_wire_position(%{}, {0, 0}, parse_wire(wire_b), 1)

    find_intersections(wire_a, wire_b)
    |> Enum.min_by(fn {point, _} ->
      steps_to_point_for_wire_positions(point, wire_a_position, wire_b_position)
    end)
    |> elem(0)
    |> steps_to_point_for_wire_positions(wire_a_position, wire_b_position)
  end

  defp steps_to_point_for_wire_positions(point, wire_a_position, wire_b_position) do
    elem(wire_a_position[point], 1) + elem(wire_b_position[point], 1)
  end

  @doc """
  Distance to closest intersection

  ## Examples

      iex> Day3.distance_to_closest_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83")
      159

  """
  def distance_to_closest_intersection(wire_a, wire_b) do
    find_intersections(wire_a, wire_b)
    |> find_closest_intersection()
    |> calculate_distance()
  end

  defp find_intersections(wire_a, wire_b) do
    wire_a_position = generate_wire_position(%{}, {0, 0}, parse_wire(wire_a), 1)
    wire_b_position = generate_wire_position(%{}, {0, 0}, parse_wire(wire_b), 1)

    wire_a_position
    |> Enum.filter(fn {point, _} -> Map.has_key?(wire_b_position, point) end)
  end

  defp find_closest_intersection(intersections) do
    Enum.min_by(intersections, fn {position, _} ->
      calculate_distance(position)
    end)
    |> elem(0)
  end

  defp calculate_distance(point) do
    abs(elem(point, 0)) + abs(elem(point, 1))
  end

  defp generate_wire_position(canvas, _, [], _) do
    canvas
  end

  defp generate_wire_position(canvas, current_position, [{_, 0} | rest], steps) do
    generate_wire_position(canvas, current_position, rest, steps)
  end

  defp generate_wire_position(canvas, {x, y}, [{:right, distance} | rest], steps) do
    updated_canvas =
      Map.update(canvas, {x + 1, y}, {1, steps}, fn {x, steps} -> {x + 1, steps} end)

    generate_wire_position(updated_canvas, {x + 1, y}, [{:right, distance - 1} | rest], steps + 1)
  end

  defp generate_wire_position(canvas, {x, y}, [{:up, distance} | rest], steps) do
    updated_canvas =
      Map.update(canvas, {x, y + 1}, {1, steps}, fn {x, steps} -> {x + 1, steps} end)

    generate_wire_position(updated_canvas, {x, y + 1}, [{:up, distance - 1} | rest], steps + 1)
  end

  defp generate_wire_position(canvas, {x, y}, [{:left, distance} | rest], steps) do
    updated_canvas =
      Map.update(canvas, {x - 1, y}, {1, steps}, fn {x, steps} -> {x + 1, steps} end)

    generate_wire_position(updated_canvas, {x - 1, y}, [{:left, distance - 1} | rest], steps + 1)
  end

  defp generate_wire_position(canvas, {x, y}, [{:down, distance} | rest], steps) do
    updated_canvas =
      Map.update(canvas, {x, y - 1}, {1, steps}, fn {x, steps} -> {x + 1, steps} end)

    generate_wire_position(updated_canvas, {x, y - 1}, [{:down, distance - 1} | rest], steps + 1)
  end

  defp parse_wire(wire) do
    wire
    |> String.split(",")
    |> Enum.map(&parse_word/1)
  end

  defp parse_word(word) do
    case String.at(word, 0) do
      "R" -> {:right, String.to_integer(String.slice(word, 1..-1))}
      "U" -> {:up, String.to_integer(String.slice(word, 1..-1))}
      "L" -> {:left, String.to_integer(String.slice(word, 1..-1))}
      "D" -> {:down, String.to_integer(String.slice(word, 1..-1))}
    end
  end
end
