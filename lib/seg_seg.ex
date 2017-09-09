defmodule SegSeg do
  @moduledoc ~S"""
  Calculates the type of relationship between two line segments **AB** and
  **CD** and the location of intersection (if applicable).

  ![Classification of segment-segment intersection](http://i.imgbox.com/hO3zHfNR.png)

  """

  @type point :: {number, number}
  @type intersection_type :: :interior
                           | :disjoint
                           | :edge
                           | :vertex
  @type intersection_result :: {boolean, intersection_type, point | nil}

  @doc ~S"""
  Returns a tuple representing the segment-segment intersectoin with three
  elements:

  1. Boolean `true` if the two segments intersect at all, `false` if they are
     disjoint
  2. An atom representing the classification of the intersection:
    * `:interior` - the segments intersect at a point that is interior to both
    * `:vertex` - the segments intersect at an endpoint of one or both segments
    * `:edge` - the segments are parallel, collinear, and overlap for some non-zero length
    * `:disjoint` - no intersection exists between the two segments
  3. A tuple `{x, y}` representing the point of intersection if the intersection
     is classified as `:interior` or `:vertex`, otherwise `nil`.

  ## Examples

      iex> SegSeg.intersection({2, -3}, {4, -1}, {2, -1}, {4, -3})
      {true, :interior, {3.0, -2.0}}
      iex> SegSeg.intersection({-1, 3}, {2, 4}, {-1, 4}, {-1, 5})
      {false, :disjoint, nil}
      iex> SegSeg.intersection({-1, 0}, {0, 2}, {0, 2}, {1, -1})
      {true, :vertex, {0, 2}}
      iex> SegSeg.intersection({-1, 0}, {0, 2}, {1, 4}, {-1, 0})
      {true, :edge, nil}
  """
  @spec intersection(point, point, point, point) :: intersection_result
  def intersection(a, b, c, d) do
    cond do
      !envelope_check(a, b, c, d) -> {false, :disjoint, nil}
      true -> do_intersection(a, b, c, d, calc_denom(a, b, c, d))
    end
  end

  @spec do_intersection(point, point, point, point, number) :: intersection_result
  defp do_intersection(a, b, c, d, denom) when denom == 0, do: parallel_int(a, b, c, d)
  defp do_intersection(a, _, c, d, _) when a == c or a == d, do: {true, :vertex, a}
  defp do_intersection(_, b, c, d, _) when b == c or b == d, do: {true, :vertex, b}
  defp do_intersection({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}, denom) do
    s = (ax * (dy - cy) + cx * (ay - dy) + dx * (cy - ay)) / denom
    t = -(ax * (cy - by) + bx * (ay - cy) + cx * (by - ay)) / denom

    cond do
      (t == 0 || t == 1) && collinear_not_between({ax, ay}, {bx, by}, {cx, cy}) -> {false, :disjoint, nil}
      (t == 0 || t == 1) && collinear_not_between({ax, ay}, {bx, by}, {dx, dy}) -> {false, :disjoint, nil}
      (s == 0 || s == 1) && collinear_not_between({cx, cy}, {dx, dy}, {ax, ay}) -> {false, :disjoint, nil}
      (s == 0 || s == 1) && collinear_not_between({cx, cy}, {dx, dy}, {bx, by}) -> {false, :disjoint, nil}
      s == 0 -> {true, :vertex, {ax, ay}}
      s == 1 -> {true, :vertex, {bx, by}}
      t == 0 -> {true, :vertex, {cx, cy}}
      t == 1 -> {true, :vertex, {dx, dy}}

      s > 0.0 && s < 1.0 && t > 0.0 && t < 1.0 -> {true, :interior, {ax + s * (bx - ax), ay + s * (by - ay)}}

      true -> {false, :disjoint, nil}
    end
  end

  @spec calc_denom(point, point, point, point) :: number
  defp calc_denom({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}) do
    ax * (dy - cy) + bx * (cy - dy) + dx * (by - ay) + cx * (ay - by)
  end

  @spec envelope_check(point, point, point, point) :: boolean
  defp envelope_check({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}) do
    cond do
      (ax < cx && ax < dx && bx < cx && bx < dx) -> false
      (ax > cx && ax > dx && bx > cx && bx > dx) -> false
      (ay < cy && ay < dy && by < cy && by < dy) -> false
      (ay > cy && ay > dy && by > cy && by > dy) -> false

      true -> true
    end
  end

  @spec parallel_int(point, point, point, point) :: intersection_result
  defp parallel_int(a, b, c, d) do
    cond do
      !collinear(a, b, c) -> {false, :disjoint, nil}

      a == c && (between(a, b, d) || between(a, d, b)) -> {true, :edge, nil}
      a == d && (between(a, b, c) || between(a, c, b)) -> {true, :edge, nil}
      b == c && (between(a, b, d) || between(b, d, a)) -> {true, :edge, nil}
      b == d && (between(a, b, c) || between(b, c, a)) -> {true, :edge, nil}

      a == c || a == d -> {true, :vertex, a}
      b == c || b == d -> {true, :vertex, b}

      true -> {true, :edge, nil}
    end
  end

  @spec collinear_not_between(point, point, point) :: boolean
  defp collinear_not_between(a, b, c) do
     collinear(a, b, c) && !between(a, b, c)
  end

  @spec collinear(point, point, point) :: boolean
  defp collinear({ax, ay}, {bx, by}, {cx, cy}) do
    Vector.cross({ax - cx, ay - cy}, {bx - cx, by - cy}) == {0, 0, 0}
  end

  @spec between(point, point, point) :: boolean
  defp between({ax, ay}, {bx, by}, {_, py}) when ax == bx, do: ((ay <= py) && (py <= by)) || ((ay >= py) && (py >= by))
  defp between({ax, _}, {bx, _}, {px, _}), do: ((ax <= px) && (px <= bx)) || ((ax >= px) && (px >= bx))
end
