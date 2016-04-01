# Segment-Segment Intersection for Elixir

[![Build Status](https://travis-ci.org/pkinney/segseg_ex.svg?branch=master)](https://travis-ci.org/pkinney/segseg_ex)
[![Hex.pm](https://img.shields.io/hexpm/v/seg_seg.svg)](https://hex.pm/packages/seg_seg)

Calculates intersection type and location for two line segments.

![Classification of segment-segment intersection](http://i.imgbox.com/7fmvvKFt.png)

## Installation

```elixir
defp deps do
  [{:seg_seg, "~> 0.1.0"}]
end
```

## Usage

**[Full Documentation](https://hexdocs.pm/seg_seg/SegSeg.html)**

The `SegSeg` module provides a function `intersection` that calculates the
intersection between two line segments and returns a tuple with three elements:

1. Boolean `true` if the two segments intersect at all, `false` if they are
   disjoint
2. An atom representing the classification of the intersection:
  * `:interior` - the segments intersect at a point that is interior to both
  * `:vertex` - the segments intersect at an endpoint of one or both segments
  * `:edge` - the segments are parallel, collinear, and overlap for some non-zero
            length
  * `:disjoint` - no intersection exists between the two segments
3. A tuple `{x, y}` representing the point of intersection if the intersection
   is classified as `:interior` or `:vertex`, otherwise `nil`.

## Examples

```elixir
SegSeg.intersection({2, -3}, {4, -1}, {2, -1}, {4, -3}) #=> {true, :interior, {3.0, -2.0}}
SegSeg.intersection({-1, 3}, {2, 4}, {-1, 4}, {-1, 5}) #=> {false, :disjoint, nil}
SegSeg.intersection({1, 2}, {3, 0}, {2, 1}, {4, 2}) #=> {true, :vertex, {2, 1}}
SegSeg.intersection({-1, 0}, {0, 2}, {1, 4}, {-1, 0}) #=> {true, :edge, nil}
```

## Tests

```bash
> mix test
```
