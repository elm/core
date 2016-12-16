module List exposing
  ( isEmpty, length, reverse, member
  , head, tail, filter, take, drop
  , repeat, range, (::), append, concat, intersperse
  , partition, unzip
  , map, map2, map3, map4, map5
  , filterMap, concatMap, indexedMap
  , foldr, foldl
  , sum, product, maximum, minimum, all, any, scanl
  , sort, sortBy, sortWith
  )

{-| A library for manipulating lists of values. Every value in a
list must have the same type.

# Basics
@docs isEmpty, length, reverse, member

# Sub-lists
@docs head, tail, filter, take, drop

# Putting Lists Together
@docs repeat, range, (::), append, concat, intersperse

# Taking Lists Apart
@docs partition, unzip

# Mapping
@docs map, map2, map3, map4, map5

If you can think of a legitimate use of `mapN` where `N` is 6 or more, please
let us know on [the list](https://groups.google.com/forum/#!forum/elm-discuss).
The current sentiment is that it is already quite error prone once you get to
4 and possibly should be approached another way.

# Special Maps
@docs filterMap, concatMap, indexedMap

# Folding
@docs foldr, foldl

# Special Folds
@docs sum, product, maximum, minimum, all, any, scanl

# Sorting
@docs sort, sortBy, sortWith

-}

import Basics exposing (..)
import Maybe
import Maybe exposing ( Maybe(Just,Nothing) )
import Native.List


{-| Add an element to the front of a list. Pronounced *cons*.

    1 :: [2,3] == [1,2,3]
    1 :: [] == [1]
-}
(::) : a -> List a -> List a
(::) =
  Native.List.cons


infixr 5 ::


{-| Extract the first element of a list.

    head [1,2,3] == Just 1
    head [] == Nothing
-}
head : List a -> Maybe a
head list =
  case list of
    x :: xs ->
      Just x

    [] ->
      Nothing


{-| Extract the rest of the list.

    tail [1,2,3] == Just [2,3]
    tail [] == Nothing
-}
tail : List a -> Maybe (List a)
tail list =
  case list of
    x :: xs ->
      Just xs

    [] ->
      Nothing


{-| Determine if a list is empty.

    isEmpty [] == True
-}
isEmpty : List a -> Bool
isEmpty xs =
  case xs of
    [] ->
      True

    _ ->
      False


{-| Figure out whether a list contains a value.

    member 9 [1,2,3,4] == False
    member 4 [1,2,3,4] == True
-}
member : a -> List a -> Bool
member x xs =
  any (\a -> a == x) xs


{-| Apply a function to every element of a list.

    map sqrt [1,4,9] == [1,2,3]

    map not [True,False,True] == [False,True,False]
-}
map : (a -> b) -> List a -> List b
map f xs =
  foldr (\x acc -> f x :: acc) [] xs


{-| Same as `map` but the function is also applied to the index of each
element (starting at zero).

    indexedMap (,) ["Tom","Sue","Bob"] == [ (0,"Tom"), (1,"Sue"), (2,"Bob") ]
-}
indexedMap : (Int -> a -> b) -> List a -> List b
indexedMap f xs =
  map2 f (range 0 (length xs - 1)) xs


{-| Reduce a list from the left.

    foldl (::) [] [1,2,3] == [3,2,1]
-}
foldl : (a -> b -> b) -> b -> List a -> b
foldl func acc list =
  case list of
    [] ->
      acc

    x :: xs ->
      foldl func (func x acc) xs


{-| Reduce a list from the right.

    foldr (+) 0 [1,2,3] == 6
-}
foldr : (a -> b -> b) -> b -> List a -> b
foldr =
  Native.List.foldr


{-| Reduce a list from the left, building up all of the intermediate results into a list.

    scanl (+) 0 [1,2,3,4] == [0,1,3,6,10]
-}
scanl : (a -> b -> b) -> b -> List a -> List b
scanl f b xs =
  let
    scan1 x accAcc =
      case accAcc of
        acc :: _ ->
          f x acc :: accAcc

        [] ->
          [] -- impossible
  in
    reverse (foldl scan1 [b] xs)


{-| Keep only elements that satisfy the predicate.

    filter isEven [1..6] == [2,4,6]
-}
filter : (a -> Bool) -> List a -> List a
filter pred xs =
  let
    conditionalCons front back =
      if pred front then
        front :: back

      else
        back
  in
    foldr conditionalCons [] xs


{-| Apply a function that may succeed to all values in the list, but only keep
the successes.

    onlyTeens =
      filterMap isTeen [3, 15, 12, 18, 24] == [15, 18]

    isTeen : Int -> Maybe Int
    isTeen n =
      if 13 <= n && n <= 19 then
        Just n

      else
        Nothing
-}
filterMap : (a -> Maybe b) -> List a -> List b
filterMap f xs =
  foldr (maybeCons f) [] xs


maybeCons : (a -> Maybe b) -> a -> List b -> List b
maybeCons f mx xs =
  case f mx of
    Just x ->
      x :: xs

    Nothing ->
      xs


{-| Determine the length of a list.

    length [1,2,3] == 3
-}
length : List a -> Int
length xs =
  foldl (\_ i -> i + 1) 0 xs


{-| Reverse a list.

    reverse [1..4] == [4,3,2,1]
-}
reverse : List a -> List a
reverse list =
  foldl (::) [] list


{-| Determine if all elements satisfy the predicate.

    all isEven [2,4] == True
    all isEven [2,3] == False
    all isEven [] == True
-}
all : (a -> Bool) -> List a -> Bool
all isOkay list =
  not (any (not << isOkay) list)


{-| Determine if any elements satisfy the predicate.

    any isEven [2,3] == True
    any isEven [1,3] == False
    any isEven [] == False
-}
any : (a -> Bool) -> List a -> Bool
any isOkay list =
  case list of
    [] ->
      False

    x :: xs ->
      -- note: (isOkay x || any isOkay xs) would not get TCO
      if isOkay x then
        True

      else
        any isOkay xs


{-| Put two lists together.

    append [1,1,2] [3,5,8] == [1,1,2,3,5,8]
    append ['a','b'] ['c'] == ['a','b','c']

You can also use [the `(++)` operator](Basics#++) to append lists.
-}
append : List a -> List a -> List a
append xs ys =
  case ys of
    [] ->
      xs

    _ ->
      foldr (::) ys xs


{-| Concatenate a bunch of lists into a single list:

    concat [[1,2],[3],[4,5]] == [1,2,3,4,5]
-}
concat : List (List a) -> List a
concat lists =
  foldr append [] lists


{-| Map a given function onto a list and flatten the resulting lists.

    concatMap f xs == concat (map f xs)
-}
concatMap : (a -> List b) -> List a -> List b
concatMap f list =
  concat (map f list)


{-| Get the sum of the list elements.

    sum [1..4] == 10
-}
sum : List number -> number
sum numbers =
  foldl (+) 0 numbers


{-| Get the product of the list elements.

    product [1..4] == 24
-}
product : List number -> number
product numbers =
  foldl (*) 1 numbers


{-| Find the maximum element in a non-empty list.

    maximum [1,4,2] == Just 4
    maximum []      == Nothing
-}
maximum : List comparable -> Maybe comparable
maximum list =
  case list of
    x :: xs ->
      Just (foldl max x xs)

    _ ->
      Nothing


{-| Find the minimum element in a non-empty list.

    minimum [3,2,1] == Just 1
    minimum []      == Nothing
-}
minimum : List comparable -> Maybe comparable
minimum list =
  case list of
    x :: xs ->
      Just (foldl min x xs)

    _ ->
      Nothing


{-| Partition a list based on a predicate. The first list contains all values
that satisfy the predicate, and the second list contains all the value that do
not.

    partition (\x -> x < 3) [0..5] == ([0,1,2], [3,4,5])
    partition isEven        [0..5] == ([0,2,4], [1,3,5])
-}
partition : (a -> Bool) -> List a -> (List a, List a)
partition pred list =
  let
    step x (trues, falses) =
      if pred x then
        (x :: trues, falses)

      else
        (trues, x :: falses)
  in
    foldr step ([],[]) list


{-| Combine two lists, combining them with the given function.
If one list is longer, the extra elements are dropped.

    map2 (+) [1,2,3] [1,2,3,4] == [2,4,6]

    map2 (,) [1,2,3] ['a','b'] == [ (1,'a'), (2,'b') ]

    pairs : List a -> List b -> List (a,b)
    pairs lefts rights =
        map2 (,) lefts rights
-}
map2 : (a -> b -> result) -> List a -> List b -> List result
map2 =
  Native.List.map2


{-|-}
map3 : (a -> b -> c -> result) -> List a -> List b -> List c -> List result
map3 =
  Native.List.map3


{-|-}
map4 : (a -> b -> c -> d -> result) -> List a -> List b -> List c -> List d -> List result
map4 =
  Native.List.map4


{-|-}
map5 : (a -> b -> c -> d -> e -> result) -> List a -> List b -> List c -> List d -> List e -> List result
map5 =
  Native.List.map5


{-| Decompose a list of tuples into a tuple of lists.

    unzip [(0, True), (17, False), (1337, True)] == ([0,17,1337], [True,False,True])
-}
unzip : List (a,b) -> (List a, List b)
unzip pairs =
  let
    step (x,y) (xs,ys) =
      (x :: xs, y :: ys)
  in
    foldr step ([], []) pairs


{-| Places the given value between all members of the given list.

    intersperse "on" ["turtles","turtles","turtles"] == ["turtles","on","turtles","on","turtles"]
-}
intersperse : a -> List a -> List a
intersperse sep xs =
  case xs of
    [] ->
      []

    hd :: tl ->
      let
        step x rest =
          sep :: x :: rest

        spersed =
          foldr step [] tl
      in
        hd :: spersed


{-| Take the first *n* members of a list.

    take 2 [1,2,3,4] == [1,2]
-}
take : Int -> List a -> List a
take n list =
  takeFast 0 n list


takeFast : Int -> Int -> List a -> List a
takeFast ctr n list =
  if n <= 0 then
    []
  else
    case ( n, list ) of
      ( _, [] ) ->
        list

      ( 1, x :: _ ) ->
        [ x ]

      ( 2, x :: y :: _ ) ->
        [ x, y ]

      ( 3, x :: y :: z :: _ ) ->
        [ x, y, z ]

      ( _, x :: y :: z :: w :: tl ) ->
        if ctr > 1000 then
          x :: y :: z :: w :: takeTailRec (n - 4) tl
        else
          x :: y :: z :: w :: takeFast (ctr + 1) (n - 4) tl

      _ ->
        list

takeTailRec : Int -> List a -> List a
takeTailRec n list =
  reverse (takeReverse n list [])


takeReverse : Int -> List a -> List a -> List a
takeReverse n list taken =
  if n <= 0 then
    taken
  else
    case list of
      [] ->
        taken

      x :: xs ->
        takeReverse (n - 1) xs (x :: taken)


{-| Drop the first *n* members of a list.

    drop 2 [1,2,3,4] == [3,4]
-}
drop : Int -> List a -> List a
drop n list =
  if n <= 0 then
    list

  else
    case list of
      [] ->
        list

      x :: xs ->
        drop (n-1) xs


{-| Create a list with *n* copies of a value:

    repeat 3 (0,0) == [(0,0),(0,0),(0,0)]
-}
repeat : Int -> a -> List a
repeat n value =
  repeatHelp [] n value


repeatHelp : List a -> Int -> a -> List a
repeatHelp result n value =
  if n <= 0 then
    result

  else
    repeatHelp (value :: result) (n-1) value


{-| Create a list of numbers, every element increasing by one.
You give the lowest and highest number that should be in the list.

    range 3 6 == [3, 4, 5, 6]
    range 3 3 == [3]
    range 6 3 == []
-}
range : Int -> Int -> List Int
range lo hi =
  rangeHelp lo hi []


rangeHelp : Int -> Int -> List Int -> List Int
rangeHelp lo hi list =
  if lo <= hi then
    rangeHelp lo (hi - 1) (hi :: list)

  else
    list


{-| Sort values from lowest to highest

    sort [3,1,5] == [1,3,5]
-}
sort : List comparable -> List comparable
sort xs =
  sortBy identity xs


{-| Sort values by a derived property.

    alice = { name="Alice", height=1.62 }
    bob   = { name="Bob"  , height=1.85 }
    chuck = { name="Chuck", height=1.76 }

    sortBy .name   [chuck,alice,bob] == [alice,bob,chuck]
    sortBy .height [chuck,alice,bob] == [alice,chuck,bob]

    sortBy String.length ["mouse","cat"] == ["cat","mouse"]
-}
sortBy : (a -> comparable) ->  List a -> List a
sortBy =
  Native.List.sortBy


{-| Sort values with a custom comparison function.

    sortWith flippedComparison [1..5] == [5,4,3,2,1]

    flippedComparison a b =
        case compare a b of
          LT -> GT
          EQ -> EQ
          GT -> LT

This is also the most general sort function, allowing you
to define any other: `sort == sortWith compare`
-}
sortWith : (a -> a -> Order) ->  List a -> List a
sortWith =
  Native.List.sortWith
