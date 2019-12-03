defmodule Day1 do
  @moduledoc """
  Documentation for Day1.
  """

  @doc """
  Fuel for all parts and fuel.

  ## Examples

      iex> Day1.total_fuel()
      5102369

  """
  def total_fuel do
    input()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&fuel_for_mass_recursive/1)
    |> Enum.sum()
  end

  @doc """
  Fuel for all parts.

  ## Examples

      iex> Day1.parts_fuel()
      3403509

  """
  def parts_fuel do
    input()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&fuel_for_mass/1)
    |> Enum.sum()
  end

  defp fuel_for_mass_recursive(mass) when mass >= 9 do
    fuel_for_mass(mass) + fuel_for_mass_recursive(fuel_for_mass(mass))
  end

  defp fuel_for_mass_recursive(mass) when mass < 9 do
    0
  end

  defp fuel_for_mass(mass) do
    div(mass, 3) - 2
  end

  defp input do
    File.read!("lib/input") |> String.split("\n")
  end
end
