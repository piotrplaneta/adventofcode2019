defmodule Day8 do
  @image_mappping %{0 => " ", 1 => "#"}
  @moduledoc """
  Documentation for Day8.
  """

  @doc """
  Image of password

  ## Examples

      iex> Day8.image()
      [" ##  #   ##  # ###  #   #", "#  # #   ## #  #  # #   #", "#     # # ##   ###   # # ", "#      #  # #  #  #   #  ", "#  #   #  # #  #  #   #  ", " ##    #  #  # ###    #  "]
  """
  def image do
    layers()
    |> Enum.reverse()
    |> Enum.reduce(Enum.at(layers, 0), fn layer, previous_layer ->
      layer
      |> Enum.with_index()
      |> Enum.reduce(previous_layer, fn {digit, index}, current_layer ->
        case digit do
          0 -> List.replace_at(current_layer, index, 0)
          1 -> List.replace_at(current_layer, index, 1)
          _ -> current_layer
        end
      end)
    end)
    |> Enum.map(fn x -> @image_mappping[x] end)
    |> Enum.chunk_every(Enum.at(input_size(), 0))
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&IO.inspect/1)
  end

  @doc """
  Checksum of layer with fewest zeros

  ## Examples

      iex> Day8.layer_with_fewest_zeros_checksum()
      2176

  """
  def layer_with_fewest_zeros_checksum do
    best_layer =
      layers()
      |> Enum.min_by(fn layer ->
        Enum.count(layer, &(&1 == 0))
      end)

    Enum.count(best_layer, &(&1 == 1)) * Enum.count(best_layer, &(&1 == 2))
  end

  defp layers() do
    input()
    |> Enum.chunk_every(input_layer_size())
  end

  defp input_layer_size() do
    Enum.at(input_size(), 0) * Enum.at(input_size(), 1)
  end

  defp input_size() do
    [25, 6]
  end

  defp input() do
    File.read!("lib/input")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
