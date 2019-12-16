defmodule Day16 do
  @moduledoc """
  Documentation for Day16.
  """

  @doc """
  Real message

  ## Examples

      iex> Day16.message(Day16.advent_input()) |> Enum.take(8)
      [4, 1, 7, 8, 1, 2, 8, 7]


  """
  def message(input) do
    5_970_443..6_499_999
    |> Enum.map(fn index ->
      Enum.at(input, rem(index, length(input)))
    end)
    |> apply_fast_phases(100)
  end

  defp apply_fast_phases(signal, 0) do
    signal
  end

  defp apply_fast_phases(signal, left_phases) do
    sum = Enum.sum(signal)

    signal
    |> Enum.reduce({[], sum}, fn elem, {acc, sum_of_digits} ->
      current =
        sum_of_digits |> to_string() |> String.graphemes() |> Enum.at(-1) |> String.to_integer()

      {[current | acc], sum_of_digits - elem}
    end)
    |> elem(0)
    |> Enum.reverse()
    |> apply_fast_phases(left_phases - 1)
  end

  @doc """
  Fft output

  ## Examples

      iex> Day16.fft_output(Day16.test_input(), 100) |> Enum.take(8)
      [2, 4, 1, 7, 6, 1, 7, 6]

      iex> Day16.fft_output(Day16.advent_input(), 100) |> Enum.take(8)
      [5, 8, 1, 0, 0, 1, 0, 5]


  """
  def fft_output(input, phases) do
    apply_phases(input, phases)
  end

  defp apply_phases(signal, 0) do
    signal
  end

  defp apply_phases(signal, left_phases) do
    calculate_new_signal(signal) |> apply_phases(left_phases - 1)
  end

  defp calculate_new_signal(signal) do
    signal
    |> Enum.with_index()
    |> Enum.map(fn {_, index} ->
      signal
      |> Enum.drop(index)
      |> Enum.chunk_every(index + 1)
      |> Enum.with_index()
      |> Enum.map(fn {group, group_index} ->
        {group, Enum.at([1, 0, -1, 0], rem(group_index, 4))}
      end)
      |> Enum.filter(fn {_, multiplier} -> multiplier == 1 || multiplier == -1 end)
      |> Enum.map(fn {group, multiplier} -> {Enum.sum(group), multiplier} end)
      |> Enum.reduce(0, fn {sum, multiplier}, acc -> acc + multiplier * sum end)
      |> to_string()
      |> String.graphemes()
      |> Enum.at(-1)
      |> String.to_integer()
    end)
  end

  def test_input do
    80_871_224_585_914_546_619_083_218_645_595
    |> to_string()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def advent_input do
    59_704_438_946_400_225_486_037_825_889_922_820_489_843_190_285_276_623_851_650_874_501_661_128_988_396_696_069_718_826_434_708_024_511_422_795_921_838_800_269_789_913_960_190_601_300_910_423_350_290_846_455_187_315_936_154_437_526_204_822_336_114_717_910_853_157_866_334_743_979_157_700_934_791_877_134_865_819_338_701_289_349_073_169_567_308_015_162_696_370_931_073_040_617_799_608_862_983_736_292_169_088_603_858_502_137_085_782_889_297_989_277_130_087_242_942_506_416_164_598_910_622_349_994_697_403_064_628_500_493_847_458_293_153_920_207_889_114_082_230_150_603_182_206_031_692_080_645_433_361_960_358_161_328_125_435_922_180_533_297_727_179_785_114_625_861_941_781_083_443_388_701_883_640_778_753_411_135_944_703_959_349_861_504_604_264_349_715_262_460_922_987_816_868_400_261_327_556_306_957_183_739_232_107_401_756_998_929_158_348_201_149_705_670_138_765_039
    |> to_string()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
