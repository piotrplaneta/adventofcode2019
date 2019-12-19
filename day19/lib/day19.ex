defmodule Day19 do
  @doc """
  ## Examples

      iex> Day19.square_coordinate()
      {790, 946}

  """
  def square_coordinate do
    min_bottom_left_y = 800
    max_bottom_left_y = 1200

    y = binary_search_bottom_y(min_bottom_left_y, max_bottom_left_y)

    {find_first_beamed_x(y), y - 99}
  end

  defp binary_search_bottom_y(min_bottom_left_y, max_bottom_left_y) do
    bottom_left_y = div(min_bottom_left_y + max_bottom_left_y, 2)

    cond do
      !check_for_bottom_left_point_y(bottom_left_y - 1) &&
          !check_for_bottom_left_point_y(bottom_left_y) ->
        binary_search_bottom_y(bottom_left_y, max_bottom_left_y)

      !check_for_bottom_left_point_y(bottom_left_y - 1) &&
          check_for_bottom_left_point_y(bottom_left_y) ->
        bottom_left_y

      check_for_bottom_left_point_y(bottom_left_y - 1) &&
          check_for_bottom_left_point_y(bottom_left_y) ->
        binary_search_bottom_y(min_bottom_left_y, bottom_left_y)
    end
  end

  defp check_for_bottom_left_point_y(bottom_left_y) do
    bottom_left_x = find_first_beamed_x(bottom_left_y)

    [
      [bottom_left_x, bottom_left_y],
      [bottom_left_x + 99, bottom_left_y - 99]
    ]
    |> Enum.all?(fn position -> evaluate_position(position) == 1 end)
  end

  defp find_first_beamed_x(y) do
    min_x = div(y, 2)

    {_, x} =
      Stream.iterate({:start, min_x}, fn {_, x} ->
        case evaluate_position([x, y]) do
          0 -> {:cont, x + 1}
          1 -> {:halt, x}
        end
      end)
      |> Enum.take_while(fn {status, _} -> status != :halt end)
      |> Enum.at(-1)

    x
  end

  @doc """
  ## Examples

      iex> Day19.points_affected_by_beam()
      226

  """
  def points_affected_by_beam do
    for(x <- 0..49, y <- 0..49, do: [x, y])
    |> Enum.map(fn pair -> evaluate_position(pair) end)
    |> Enum.sum()
  end

  defp evaluate_position(position) do
    Stream.iterate(
      {:start, position, [], init_computer_state(), 0},
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

  defp init_computer_state do
    0..length(input())
    |> Stream.zip(input())
    |> Enum.into(%{})
    |> Map.put(-1, 0)
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
