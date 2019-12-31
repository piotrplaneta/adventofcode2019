defmodule Day22 do
  @doc """
  ## Examples

      iex> Day22.card_position_after_shuffles(10007, Day22.advent_input(), 2019)
      11

  """
  def card_position_after_shuffles(number_of_cards, techniques, card) do
    shuffle(number_of_cards, techniques)
    |> Enum.find_index(&(&1 == card))
  end

  @doc """
  ## Examples

      iex> Day22.shuffle(10, Day22.test_input())
      [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]

  """
  def shuffle(number_of_cards, techniques) do
    0..(number_of_cards - 1)
    |> Enum.to_list()
    |> apply_shuffles(techniques)
  end

  defp apply_shuffles(deck, techniques) do
    techniques
    |> Enum.reduce(deck, fn technique, current_deck -> apply_shuffle(current_deck, technique) end)
  end

  defp apply_shuffle(deck, "deal into new stack") do
    Enum.reverse(deck)
  end

  defp apply_shuffle(deck, "cut " <> n) do
    n = String.to_integer(n)
    apply_cut(deck, n)
  end

  defp apply_shuffle(deck, "deal with increment " <> increment) do
    divisor = length(deck)
    increment = String.to_integer(increment)

    deck
    |> Enum.reduce({%{}, 0}, fn card, {current_deck, index} ->
      {Map.put(current_deck, index, card), rem(index + increment, divisor)}
    end)
    |> elem(0)
    |> Enum.to_list()
    |> Enum.sort(fn {k1, _}, {k2, _} -> k1 < k2 end)
    |> Enum.map(fn {_, v} -> v end)
  end

  defp apply_cut(deck, n) when n > 0 do
    Enum.drop(deck, n) ++ Enum.take(deck, n)
  end

  defp apply_cut(deck, n) when n < 0 do
    Enum.take(deck, n) ++ Enum.take(deck, length(deck) + n)
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
