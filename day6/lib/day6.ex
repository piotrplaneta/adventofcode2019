defmodule Day6 do
  @moduledoc """
  Documentation for Day6.
  """

  @doc """
  Number of hops for advent input

  ## Examples

      iex> Day6.number_of_hops_for_advent_input()
      451

  """
  def number_of_hops_for_advent_input() do
    parse_input()
    |> number_of_hops()
  end

  @doc """
  Number of hops

  ## Examples

      iex> Day6.number_of_hops(["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L", "K)YOU", "I)SAN"])
      4

  """
  def number_of_hops(input) do
    children_list = parse_tree(input)

    calculate_number_of_hops(children_list)
  end

  @doc """
  Number of orbits for advent input

  ## Examples

      iex> Day6.number_of_orbits_for_advent_input()
      270768

  """
  def number_of_orbits_for_advent_input() do
    parse_input()
    |> number_of_orbits()
  end

  @doc """
  Number of orbits

  ## Examples

      iex> Day6.number_of_orbits(["COM)B", "B)C", "C)D", "D)E", "E)F", "B)G", "G)H", "D)I", "E)J", "J)K", "K)L"])
      42

  """
  def number_of_orbits(input) do
    children_list = parse_tree(input)

    calculate_number_of_orbits(children_list["COM"], children_list, 0)
  end

  defp parse_tree(input) do
    children_list =
      Enum.reduce(input, %{}, fn x, acc ->
        [center | [orbitee | _]] = String.split(x, ")")
        Map.update(acc, center, [orbitee], fn orbitees -> [orbitee | orbitees] end)
      end)

    children_list
  end

  defp calculate_number_of_hops(children_list) do
    rank_of_me_node = calculate_rank("YOU", children_list["COM"], children_list, 1)
    rank_of_santa_node = calculate_rank("SAN", children_list["COM"], children_list, 1)

    rank_of_common_ancestor =
      common_ancestor("YOU", "SAN", "COM", children_list)
      |> calculate_rank(children_list["COM"], children_list, 1)

    rank_of_me_node + rank_of_santa_node - 2 * rank_of_common_ancestor - 2
  end

  defp calculate_rank(_, nil, _, _) do
    -1
  end

  defp calculate_rank(searched_node, current_node_children, children_list, rank) do
    if Enum.any?(current_node_children, fn child -> child == searched_node end) do
      rank
    else
      Enum.max(
        Enum.map(current_node_children, fn child ->
          calculate_rank(searched_node, children_list[child], children_list, rank + 1)
        end)
      )
    end
  end

  defp common_ancestor(node_a, _, node_a, _) do
    node_a
  end

  defp common_ancestor(_, node_b, node_b, _) do
    node_b
  end

  defp common_ancestor(node_a, node_b, current_node, children_list) do
    common_ancestor_in_children =
      Enum.map(children_list[current_node] || [], fn child ->
        common_ancestor(node_a, node_b, child, children_list)
      end)
      |> Enum.filter(&(!is_nil(&1)))

    case length(common_ancestor_in_children) do
      0 ->
        nil

      1 ->
        common_ancestor_in_children
        |> Enum.at(0)

      2 ->
        current_node
    end
  end

  defp calculate_number_of_orbits(nil, _, step) do
    step
  end

  defp calculate_number_of_orbits(current_node_children, children_list, step) do
    step +
      Enum.sum(
        Enum.map(current_node_children, fn child ->
          calculate_number_of_orbits(children_list[child], children_list, step + 1)
        end)
      )
  end

  defp parse_input() do
    File.read!("lib/input") |> String.split("\n")
  end
end
