defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  @doc """
  Advanced Password count. It uses the fact that to have an exactly pair of the
  same digits in the number that is not decreasing, they need to be adjacent.

  ## Examples

      iex> Day4.advanced_password_count()
      334

  """
  def advanced_password_count do
    356_261..846_303
    |> Enum.filter(fn x -> two_adjacent_same_digits?(x) && not_decreasing?(x) end)
    |> Enum.filter(fn x -> has_any_pair?(x) end)
    |> length()
  end

  @doc """
  Simple Password count.

  ## Examples

      iex> Day4.simple_password_count()
      544

  """
  def simple_password_count do
    356_261..846_303
    |> Enum.filter(fn x -> two_adjacent_same_digits?(x) && not_decreasing?(x) end)
    |> length()
  end

  defp two_adjacent_same_digits?(number) do
    number
    |> Integer.to_string()
    |> String.split("")
    |> Enum.drop(-1)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn pair -> Enum.at(pair, 0) == Enum.at(pair, 1) end)
  end

  defp not_decreasing?(number) do
    number
    |> Integer.to_string()
    |> String.split("")
    |> Enum.drop(-1)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn pair -> Enum.at(pair, 0) <= Enum.at(pair, 1) end)
  end

  defp has_any_pair?(number) do
    number
    |> Integer.to_string()
    |> String.split("")
    |> Enum.drop(-1)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.group_by(& &1)
    |> Enum.map(fn {digit, digits} -> {digit, length(digits)} end)
    |> Enum.any?(fn {_, count} -> count == 2 end)
  end
end
