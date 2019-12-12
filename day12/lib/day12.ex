defmodule Day12 do
  @moduledoc """
  Documentation for Day12.
  """

  @doc """
  Steps it takes for universe to get back

  ## Examples

      iex> Day12.steps_for_back_to_first_step([{5, 13, -3}, {18, -7, 13}, {16, 3, 4}, {0, 8, 8}])
      271442326847376

  """
  def steps_for_back_to_first_step(initial_bodies) do
    [x_steps | [y_steps | [z_steps | _]]] =
      0..2
      |> Enum.map(fn coordinate ->
        update_system(initial_bodies, initial_velocities())
        |> Stream.iterate(fn {bodies, velocities} ->
          update_system(bodies, velocities)
        end)
        |> Enum.take_while(fn {bs, vs} ->
          Enum.map(bs, &elem(&1, coordinate)) != Enum.map(initial_bodies, &elem(&1, coordinate)) ||
            Enum.map(vs, &elem(&1, coordinate)) != [0, 0, 0, 0]
        end)
        |> (&(length(&1) + 1)).()
      end)

    lcm(x_steps, y_steps) |> lcm(z_steps)
  end

  @doc """
  Total energy after x steps

  ## Examples

      iex> Day12.total_energy_after_steps([{5, 13, -3}, {18, -7, 13}, {16, 3, 4}, {0, 8, 8}], 1000)
      10198

  """
  def total_energy_after_steps(bodies, steps) do
    Stream.iterate({bodies, initial_velocities()}, fn {bodies, velocities} ->
      update_system(bodies, velocities)
    end)
    |> Enum.take(steps + 1)
    |> List.last()
    |> calculate_energy()
  end

  defp update_system(bodies, velocities) do
    updated_velocities = update_velocities(velocities, bodies)
    updated_bodies = update_body_positions(bodies, updated_velocities)

    {updated_bodies, updated_velocities}
  end

  defp update_velocities(velocities, bodies) do
    Enum.zip(velocities, bodies)
    |> Enum.map(fn {velocity, body} ->
      {update_velocity_dimension(velocity, 0, body, bodies_without(bodies, body)),
       update_velocity_dimension(velocity, 1, body, bodies_without(bodies, body)),
       update_velocity_dimension(velocity, 2, body, bodies_without(bodies, body))}
    end)
  end

  defp bodies_without(bodies, body) do
    Enum.filter(bodies, fn b -> b != body end)
  end

  defp update_velocity_dimension({vel_x, _, _}, 0, {body_x, _, _}, other_bodies) do
    calculate_gravitational_pull(vel_x, 0, body_x, other_bodies)
  end

  defp update_velocity_dimension({_, vel_y, _}, 1, {_, body_y, _}, other_bodies) do
    calculate_gravitational_pull(vel_y, 1, body_y, other_bodies)
  end

  defp update_velocity_dimension({_, _, vel_z}, 2, {_, _, body_z}, other_bodies) do
    calculate_gravitational_pull(vel_z, 2, body_z, other_bodies)
  end

  defp calculate_gravitational_pull(initial_value, dimension, body_position, other_bodies) do
    initial_value +
      Enum.reduce(other_bodies, 0, fn b, sum ->
        cond do
          elem(b, dimension) > body_position -> sum + 1
          elem(b, dimension) == body_position -> sum
          elem(b, dimension) < body_position -> sum - 1
        end
      end)
  end

  defp update_body_positions(bodies, velocities) do
    Enum.zip(bodies, velocities)
    |> Enum.map(fn {{b_x, b_y, b_z}, {v_x, v_y, v_z}} -> {b_x + v_x, b_y + v_y, b_z + v_z} end)
  end

  defp initial_velocities() do
    replicate({0, 0, 0}, 4)
  end

  defp replicate(x, n), do: for(_ <- 1..n, do: x)

  defp calculate_energy({bodies, velocities}) do
    Enum.zip(bodies, velocities)
    |> Enum.map(fn {{b_x, b_y, b_z}, {v_x, v_y, v_z}} ->
      (abs(b_x) + abs(b_y) + abs(b_z)) * (abs(v_x) + abs(v_y) + abs(v_z))
    end)
    |> Enum.sum()
  end

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp lcm(a, b), do: div(abs(a * b), gcd(a, b))
end
