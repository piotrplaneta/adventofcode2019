defmodule Day13 do
  @doc """
  Game result for advent_input

  ## Examples

      iex> Day13.game_result_for_advent_input()
      21426

  """
  def game_result_for_advent_input() do
    initial_state =
      0..length(input())
      |> Stream.zip(input())
      |> Enum.into(%{})
      |> Map.put(-1, 0)
      |> Map.put(0, 2)

    play_the_game(initial_state, 0, [])
  end

  defp play_the_game(state, step, inputs, previous_paddle_x \\ -1) do
    {instruction, state, step, outputs} =
      execute_instructions_till_input_requested(state, step, inputs)

    case instruction do
      :halt ->
        outputs |> Enum.at(-1) |> Enum.at(-1)

      :input ->
        {input, paddle_x} = paddle_move(outputs, previous_paddle_x)
        play_the_game(state, step, [input], paddle_x)
    end
  end

  defp execute_instructions_till_input_requested(state, step, inputs) do
    steps =
      Stream.iterate({:start, inputs, [], state, step}, fn {_, inputs, _, state, step} ->
        IntCodeComputer.run(state, step, inputs)
      end)
      |> Enum.take_while(fn {instruction, _, _, _, _} ->
        instruction != :halt && instruction != :input
      end)

    {operation, _, _, updated_state, updated_step} =
      IntCodeComputer.run(elem(Enum.at(steps, -1), 3), elem(Enum.at(steps, -1), 4), [])

    outputs =
      steps
      |> Enum.filter(fn {mode, _, _, _, _} -> mode == :output end)
      |> Enum.map(fn {_, _, output, _, _} -> output end)
      |> Enum.chunk_every(3)

    {operation, updated_state, updated_step, outputs}
  end

  defp paddle_move(outputs, previous_paddle_x) do
    [paddle_x | _] =
      [[previous_paddle_x, nil, 3] | outputs]
      |> Enum.filter(fn [_ | [_ | [tile_id]]] -> tile_id == 3 end)
      |> Enum.at(-1)

    [ball_x | _] =
      outputs
      |> Enum.filter(fn [_ | [_ | [tile_id]]] -> tile_id == 4 end)
      |> Enum.at(-1)

    cond do
      ball_x > paddle_x -> {1, paddle_x}
      ball_x == paddle_x -> {0, paddle_x}
      ball_x < paddle_x -> {-1, paddle_x}
    end
  end

  @doc """
  Block count for advent_input

  ## Examples

      iex> Day13.block_count_for_advent_input()
      427

  """
  def block_count_for_advent_input() do
    input() |> block_count()
  end

  defp block_count(instructions) do
    initial_state =
      0..length(instructions)
      |> Stream.zip(instructions)
      |> Enum.into(%{})
      |> Map.put(-1, 0)

    Stream.iterate({:start, [], [], initial_state, 0}, fn {_, _, _, state, step} ->
      IntCodeComputer.run(state, step, [])
    end)
    |> Enum.take_while(fn {instruction, _, _, _, _} -> instruction != :halt end)
    |> Enum.filter(fn {mode, _, _, _, _} -> mode == :output end)
    |> Enum.map(fn {_, _, output, _, _} -> output end)
    |> Enum.chunk_every(3)
    |> Enum.filter(fn [_ | [_ | [tile_id]]] -> tile_id == 2 end)
    |> length()
  end

  defp input do
    File.read!("lib/input")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
