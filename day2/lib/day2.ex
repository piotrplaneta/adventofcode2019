defmodule Day2 do
  @moduledoc """
  Documentation for Day2.
  """

  @doc """
  Noun and verb for gravity_assist

  ## Examples

      iex> Day2.noun_and_verb_for_gravity_assist()
      {95, 7, 19690720}

  """
  def noun_and_verb_for_gravity_assist do
    outputs = for i <- 1..99, j <- 1..99, do: {i, j, output_with_given_input(i, j)}
    Enum.find(outputs, fn x -> elem(x, 2) == 19_690_720 end)
  end

  @doc """
  Output for given noun and verb.

  ## Examples

      iex> Day2.output_with_given_input(1, 1)
      439514

  """
  def output_with_given_input(noun, verb) do
    input_with_noun_and_verb =
      input()
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)

    Enum.at(evaluate_steps(input_with_noun_and_verb, 0), 0)
  end

  @doc """
  Output.

  ## Examples

      iex> Day2.output()
      2692315

  """
  def output do
    Enum.at(evaluate_steps(input(), 0), 0)
  end

  defp evaluate_steps(state, step) do
    case Enum.at(state, step) do
      99 ->
        state

      1 ->
        result = sum_at_positions(state, step + 1, step + 2)
        result_index = Enum.at(state, step + 3)
        evaluate_steps(List.replace_at(state, result_index, result), step + 4)

      2 ->
        result = product_at_positions(state, step + 1, step + 2)
        result_index = Enum.at(state, step + 3)
        evaluate_steps(List.replace_at(state, result_index, result), step + 4)
    end
  end

  defp sum_at_positions(state, position_a, position_b) do
    Enum.at(state, Enum.at(state, position_a)) + Enum.at(state, Enum.at(state, position_b))
  end

  defp product_at_positions(state, position_a, position_b) do
    Enum.at(state, Enum.at(state, position_a)) * Enum.at(state, Enum.at(state, position_b))
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
