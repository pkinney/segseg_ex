defmodule SegSeg do
  @moduledoc ~S"""
  Calculates the type of relationship between two line segments **AB** and
  **CD** and the location of intersection (if applicable).

  ![Classification of segment-segment intersection](http://i.imgbox.com/hO3zHfNR.png)

  """

  @type point :: {number, number}
  @type intersection_type ::
          :interior
          | :disjoint
          | :edge
          | :vertex
  @type intersection_result :: {boolean, intersection_type, point | nil}

  # When the `epsilon` option is passed as `true` or a number, certain comparisons are broadened
  # based on an epsilon value. 
  # If `true` is passed, the eps value is defined as the smaller of the distances
  # of each segment multiplied by the `@eps_factor` below.
  @eps_factor 0.000000001

  @doc ~S"""
  Returns a tuple representing the segment-segment intersection with three
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

  ## Float Precision Issues

  It is possible that floating point math imprecision can cause incorrect results for
  certain inputs.  In situations where this may cause issues, an `epsilon` options is
  available.  When set to `true` intersection comparisons are made with a very small `epsilon` based on the minimum
  of the lengths of the provided segment times a very small number (currently 0.0000000001). `epsilon` can also be set to a specific number that will be used as the epsilon value.
  This eliminates most rounding error, but of course could cause false results in certain
  situations. This currently only effects `:vertex` results but might be expanded to `:edge`
  in the future.

  ```elixir
  SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}) #=> {true, :interior, {4.0, 6.999999999999998}}
  SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, epsilon: true) #=> {true, :vertex, {4, 7}}
  ```

  ## Examples

      iex> SegSeg.intersection({2, -3}, {4, -1}, {2, -1}, {4, -3})
      {true, :interior, {3.0, -2.0}}
      iex> SegSeg.intersection({-1, 3}, {2, 4}, {-1, 4}, {-1, 5})
      {false, :disjoint, nil}
      iex> SegSeg.intersection({-1, 0}, {0, 2}, {0, 2}, {1, -1})
      {true, :vertex, {0, 2}}
      iex> SegSeg.intersection({-1, 0}, {0, 2}, {1, 4}, {-1, 0})
      {true, :edge, nil}
      iex> SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, epsilon: true)
      {true, :vertex, {4, 7}}

      # A intersection that fails the specified epsilon
      iex> SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, epsilon: 0.00000000000000000001)
      {true, :interior, {4.0, 6.999999999999998}}
  """
  @spec intersection(point, point, point, point, keyword()) :: intersection_result
  def intersection(a, b, c, d, options \\ []) do
    if envelope_check(a, b, c, d) do
      denom = calc_denom(a, b, c, d)
      eps = calc_eps(a, b, c, d, options)
      do_intersection(a, b, c, d, denom, eps)
    else
      {false, :disjoint, nil}
    end
  end

  defp do_intersection(a, b, c, d, denom, _) when denom == 0, do: parallel_int(a, b, c, d)
  defp do_intersection(a, _, c, d, _, _) when a == c or a == d, do: {true, :vertex, a}
  defp do_intersection(_, b, c, d, _, _) when b == c or b == d, do: {true, :vertex, b}

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp do_intersection({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}, denom, eps) do
    s = (ax * (dy - cy) + cx * (ay - dy) + dx * (cy - ay)) / denom
    t = -(ax * (cy - by) + bx * (ay - cy) + cx * (by - ay)) / denom

    t_zero = t >= -eps && t <= eps
    t_one = t >= 1.0 - eps && t <= 1.0 + eps
    s_zero = s >= -eps && s <= eps
    s_one = s >= 1.0 - eps && s <= 1.0 + eps

    cond do
      (t_zero || t_one) && collinear_not_between({ax, ay}, {bx, by}, {cx, cy}) ->
        {false, :disjoint, nil}

      (t_zero || t_one) && collinear_not_between({ax, ay}, {bx, by}, {dx, dy}) ->
        {false, :disjoint, nil}

      (s_zero || s_one) && collinear_not_between({cx, cy}, {dx, dy}, {ax, ay}) ->
        {false, :disjoint, nil}

      (s_zero || s_one) && collinear_not_between({cx, cy}, {dx, dy}, {bx, by}) ->
        {false, :disjoint, nil}

      s_zero ->
        {true, :vertex, {ax, ay}}

      s_one ->
        {true, :vertex, {bx, by}}

      t_zero ->
        {true, :vertex, {cx, cy}}

      t_one ->
        {true, :vertex, {dx, dy}}

      s > 0.0 && s < 1.0 && t > 0.0 && t < 1.0 ->
        {true, :interior, {ax + s * (bx - ax), ay + s * (by - ay)}}

      true ->
        {false, :disjoint, nil}
    end
  end

  defp calc_eps(a, b, c, d, options) do
    case Keyword.get(options, :epsilon, false) do
      false -> 0.0
      true -> eps_factor(a, b, c, d)
      num when is_number(num) -> num
    end
  end

  defp eps_factor({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}) do
    ab_dist = (ax - bx) * (ax - bx) + (ay - by) * (ay - by)
    cd_dist = (cx - dx) * (cx - dx) + (cy - dy) * (cy - dy)
    :math.sqrt(min(ab_dist, cd_dist)) * @eps_factor
  end

  defp calc_denom({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}) do
    ax * (dy - cy) + bx * (cy - dy) + dx * (by - ay) + cx * (ay - by)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp envelope_check({ax, ay}, {bx, by}, {cx, cy}, {dx, dy}) do
    cond do
      ax < cx && ax < dx && bx < cx && bx < dx -> false
      ax > cx && ax > dx && bx > cx && bx > dx -> false
      ay < cy && ay < dy && by < cy && by < dy -> false
      ay > cy && ay > dy && by > cy && by > dy -> false
      true -> true
    end
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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

  defp collinear_not_between(a, b, c) do
    collinear(a, b, c) && !between(a, b, c)
  end

  defp collinear({ax, ay}, {bx, by}, {cx, cy}) do
    Vector.cross({ax - cx, ay - cy}, {bx - cx, by - cy}) == {0, 0, 0}
  end

  defp between({ax, ay}, {bx, by}, {_, py}) when ax == bx,
    do: (ay <= py && py <= by) || (ay >= py && py >= by)

  defp between({ax, _}, {bx, _}, {px, _}), do: (ax <= px && px <= bx) || (ax >= px && px >= bx)
end
