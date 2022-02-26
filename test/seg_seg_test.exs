defmodule SegSegTest do
  use ExUnit.Case
  doctest SegSeg
  import SegSeg

  test "interior intersection" do
    assert {true, :interior, {0.0, 0.0}} = permutations({-1, -1}, {1, 1}, {-1, 1}, {1, -1})
    assert {true, :interior, {0.75, 0.0}} = permutations({-1, 0}, {1, 0}, {0.5, -1}, {1, 1})
    assert {true, :interior, {_, _}} = intersection({-1, -1}, {0, 0.0000001}, {-1, 1}, {1, -1})
  end

  test "vertex" do
    assert {true, :vertex, {0, 0}} = intersection({-1, -1}, {0, 0}, {-1, 1}, {1, -1})
    assert {true, :vertex, {0, 0}} = intersection({0, 0}, {1, 1}, {0, 0}, {-1, -1})
    assert {true, :vertex, {0.5, 0}} = permutations({-1, 0}, {1, 0}, {0.5, 0}, {1, 1})
    assert {true, :vertex, {2, 1}} = permutations({1, 2}, {3, 0}, {2, 1}, {4, 2})
    assert {true, :vertex, {80, 50}} = permutations({20, 20}, {80, 50}, {80, 50}, {110, 65})
    assert {true, :vertex, {20, 20}} = permutations({20, 20}, {80, 140}, {20, 20}, {20, 180})
  end

  test "vertex (non-strict mode)" do
    # This is a known-bad set of inputs that produce rounding error and return incorrect results
    # only when strict mode is enabled.
    assert {true, :interior, _} =
             intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, strict: true)

    assert {true, :vertex, {4, 7}} =
             intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, strict: false)
  end

  test "edge" do
    assert {true, :edge, nil} = intersection({20, 20}, {80, 50}, {80, 50}, {50, 35})
    assert {true, :edge, nil} = permutations({0, 0}, {1, 1}, {0, 0}, {2, 2})
    assert {true, :edge, nil} = intersection({-1, 0}, {0, 2}, {1, 4}, {-1, 0})
    assert {true, :edge, nil} = permutations({-1, 0}, {1, 0}, {0.5, 0}, {1.5, 0})
    assert {true, :edge, nil} = permutations({-1, 0}, {1, -1.5}, {-1, 0}, {1, -1.5})
  end

  test "disjoint, not parallel" do
    assert {false, :disjoint, nil} = permutations({-1, 0}, {1, 0}, {0.5, -1}, {1, -1.5})
    assert {false, :disjoint, nil} = permutations({-1, 0}, {0, 0}, {1, 1}, {1, -1})
    assert {false, :disjoint, nil} = permutations({1, 3}, {-1, 0}, {-1, -1}, {-2, 0})
  end

  test "disjoint, parallel" do
    assert {false, :disjoint, nil} = permutations({20, 20}, {80, 50}, {25, 45}, {55, 60})
  end

  test "disjoint, collinear" do
    assert {false, :disjoint, nil} = permutations({20, 20}, {80, 50}, {75, 45}, {105, 60})
    assert {false, :disjoint, nil} = permutations({20, 20}, {30, 25}, {40, 30}, {50, 35})
    assert {false, :disjoint, nil} = permutations({20, 20}, {80, 50}, {90, 55}, {110, 65})
  end

  def permutations(a, b, c, d) do
    result = intersection(a, b, c, d)
    assert result == intersection(b, a, c, d)
    assert result == intersection(a, b, d, c)
    assert result == intersection(b, a, d, c)
    assert result == intersection(c, d, a, b)
    assert result == intersection(d, c, a, b)
    assert result == intersection(c, d, b, a)
    assert result == intersection(d, c, b, a)
    assert result == intersection(a, b, c, d, strict: false)
    assert result == intersection(b, a, c, d, strict: false)
    assert result == intersection(a, b, d, c, strict: false)
    assert result == intersection(b, a, d, c, strict: false)
    assert result == intersection(c, d, a, b, strict: false)
    assert result == intersection(d, c, a, b, strict: false)
    assert result == intersection(c, d, b, a, strict: false)
    assert result == intersection(d, c, b, a, strict: false)
    result
  end
end
