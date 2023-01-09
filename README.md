# Segment-Segment Intersection for Elixir

![Build Status](https://github.com/pkinney/segseg_ex/actions/workflows/ci.yaml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/seg_seg.svg)](https://hex.pm/packages/seg_seg)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/seg_seg)


Calculates intersection type and location for two line segments.

![Classification of segment-segment intersection](http://i.imgbox.com/hO3zHfNR.png)

## Installation

```elixir
defp deps do
  [{:seg_seg, "~> 1.0"}]
end
```

## Usage

**[Full Documentation](https://hexdocs.pm/seg_seg/SegSeg.html)**

The `SegSeg` module provides a function `intersection` that calculates the
intersection between two line segments and returns a tuple with three elements:

1. Boolean `true` if the two segments intersect at all, `false` if they are
   disjoint
2. An atom representing the classification of the intersection:

- `:interior` - the segments intersect at a point that is interior to both
- `:vertex` - the segments intersect at an endpoint of one or both segments
- `:edge` - the segments are parallel, collinear, and overlap for some non-zero
  length
- `:disjoint` - no intersection exists between the two segments

3. A tuple `{x, y}` representing the point of intersection if the intersection
   is classified as `:interior` or `:vertex`, otherwise `nil`.

## Examples

```elixir
SegSeg.intersection({2, -3}, {4, -1}, {2, -1}, {4, -3}) #=> {true, :interior, {3.0, -2.0}}
SegSeg.intersection({-1, 3}, {2, 4}, {-1, 4}, {-1, 5}) #=> {false, :disjoint, nil}
SegSeg.intersection({1, 2}, {3, 0}, {2, 1}, {4, 2}) #=> {true, :vertex, {2, 1}}
SegSeg.intersection({-1, 0}, {0, 2}, {1, 4}, {-1, 0}) #=> {true, :edge, nil}
```

## Float Precision Issues

It is possible that floating point math imprecision can cause incorrect results for certain inputs.  In situations where this may cause issues, an `epsilon` options is available.  When set to `true` intersection comparisons are made with a very small `epsilon` based on the minimum of the lengths of the provided segment times a very small number (currently 0.0000000001). `epsilon` can also be set to a specific number that will be used as the epsilon value. This eliminates most rounding error, but of course could cause false results in certain situations. This currently only effects `:vertex` results but might be expanded to `:edge` in the future.

```elixir
SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}) #=> {true, :interior, {4.0, 6.999999999999998}}
SegSeg.intersection({4, 3}, {4, 7}, {6.05, 9.05}, {3.95, 6.95}, epsilon: true) #=> {true, :vertex, {4, 7}}
```

## Tests

```bash
> mix test
```
