module Tuple exposing
  ( first, second
  , mapFirst, mapSecond
  )

{-| Some helpers for working with 2-tuples.

**Note:** For larger chunks of data, it is best to switch to using records. So
instead of representing a 3D point as `(3,4,5)` and wondering why there are no
helper functions, represent it as `{ x = 3, y = 4, z = 5 }` and use all the
built-in syntax for records.

@docs first, second, mapFirst, mapSecond

-}



{-| Extract the first value from a tuple.

    first (3, 4) == 3
    first ("john", "doe") == "john"
-}
first : (a1, a2) -> a1
first (x,_) =
  x


{-| Extract the second value from a tuple.

    second (3, 4) == 4
    second ("john", "doe") == "doe"
-}
second : (a1, a2) -> a2
second (_,y) =
  y


{-| Transform the first value in a tuple.

    import String

    mapFirst String.reverse ("stressed", 16) == ("desserts", 16)
    mapFirst String.length  ("stressed", 16) == (8, 16)
-}
mapFirst : (a -> b) -> (a, a2) -> (b, a2)
mapFirst func (x,y) =
  (func x, y)


{-| Transform the second value in a tuple.

    import String

    mapSecond sqrt          ("stressed", 16) == ("stressed", 4)
    mapSecond (\x -> x + 1) ("stressed", 16) == ("stressed", 17)
-}
mapSecond : (a -> b) -> (a1, a) -> (a1, b)
mapSecond func (x,y) =
  (x, func y)

