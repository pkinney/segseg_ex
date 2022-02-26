defmodule VertexTest do
  use ExUnit.Case

  @circle [
    {0, 1},
    {1, 1},
    {1, 0},
    {1, -1},
    {0, -1},
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {1, 2},
    {2, 1},
    {2, -1},
    {1, -2},
    {-1, -2},
    {-2, -1},
    {-2, 1},
    {-1, 2}
  ]

  test "all the vertix intersections around a single point" do
    for b <- @circle, d <- @circle do
      if b == d do
        assert {true, :edge, nil} == SegSegTest.permutations({0, 0}, b, {0, 0}, d)
      else
        assert {true, :vertex, {0, 0}} == SegSegTest.permutations({0, 0}, b, {0, 0}, d)
      end
    end
  end
end
