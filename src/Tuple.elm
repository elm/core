module Tuple exposing
  ( first, second
  , mapFirst, mapSecond, mapBoth
  )

{-| Some helpers for working with 2-tuples.

**Note:** For larger chunks of data, it is best to switch to using records. So
instead of representing a 3D point as `(3,4,5)` and wondering why there are no
helper functions, represent it as `{ x = 3, y = 4, z = 5 }` and use all the
built-in syntax for records.

# Accessors
@docs first, second

# Mapping
@docs mapFirst, mapSecond

-}



{-| Extract the first value from a tuple.

    first (3, 4) == 3
    first ("john", "doe") == "john"
-}
first : (a, b) -> a
first (x,_) =
  x


{-| Extract the second value from a tuple.

    second (3, 4) == 4
    second ("john", "doe") == "doe"
-}
second : (a, b) -> b
second (_,y) =
  y


{-| Transform the first value in a tuple.

    import String

    mapFirst String.reverse ("stressed", 16) == ("desserts", 16)
    mapFirst String.length  ("stressed", 16) == (8, 16)
-}
mapFirst : (a1 -> a2) -> (a1, b) -> (a2, b)
mapFirst func (x,y) =
  (func x, y)


{-| Transform the second value in a tuple.

    import String

    mapSecond sqrt          ("stressed", 16) == ("stressed", 4)
    mapSecond (\x -> x + 1) ("stressed", 16) == ("stressed", 17)
-}
mapSecond : (b1 -> b2) -> (a, b1) -> (a, b2)
mapSecond func (x,y) =
  (x, func y)


{-| Transform both values in a tuple.

    mapBoth ((+) 1) (6, 8) == (7, 9)
-}
mapBoth : (a -> b) -> (a, a) -> (b, b)
mapBoth func (x,y) =
    (func x, func y)

