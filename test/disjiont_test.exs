defmodule DisjointTest do
  use ExUnit.Case

  @segments [
    {{0, 0}, {1, 1}},
    {{1, 4}, {2, 4}},
    {{1, 6}, {3, 6}},
    {{2, 2}, {2, 3}},
    {{3, 1}, {3, 2}},
    {{3, 3}, {5, 5}},
    {{3, 4}, {3, 5}},
    {{4, 1}, {6, 3}},
    {{4, 2}, {4, 3}},
    {{4, 5}, {4, 6}},
    {{5, 3}, {5, 4}},
    {{5, 6}, {5, 7}},
    {{6, 5}, {7, 5}},
    {{6, 6}, {8, 8}},
    {{7, 1}, {7, 2}},
    {{7, 3}, {7, 4}},
    {{7, 6}, {9, 4}},
    {{9, 5}, {11, 3}},
    {{10, 3}, {11, 2}},
    {{10, 5}, {11, 5}}
  ]

  test "all the disjoint" do
    for {ax, ay} <- @segments, {bx, by} <- @segments do
      if ax == bx && ay == by do
        assert {true, :edge, nil} == SegSegTest.permutations(ax, ay, bx, by)
      else
        assert {false, :disjoint, nil} == SegSegTest.permutations(ax, ay, bx, by)
      end
    end
  end
end
