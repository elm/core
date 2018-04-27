module Set exposing
  ( Set
  , empty, singleton, insert, remove
  , isEmpty, member, size
  , union, intersect, diff
  , toList, fromList
  , map, foldl, foldr, filter, keepIf, dropIf, partition
  )

{-| A set of unique values. The values can be any comparable type. This
includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or lists
of comparable types.

Insert, remove, and query operations all take *O(log n)* time.

# Sets
@docs Set

# Build
@docs empty, singleton, insert, remove

# Query
@docs isEmpty, member, size

# Combine
@docs union, intersect, diff

# Lists
@docs toList, fromList

# Transform
@docs map, foldl, foldr, filter, keepIf, dropIf, partition

-}

import Basics exposing (Bool, Int)
import Dict
import List exposing ((::))
import Maybe exposing (Maybe(..))


{-| Represents a set of unique values. So `(Set Int)` is a set of integers and
`(Set String)` is a set of strings.
-}
type Set t =
  Set_elm_builtin (Dict.Dict t ())


{-| Create an empty set.
-}
empty : Set a
empty =
  Set_elm_builtin Dict.empty


{-| Create a set with one value.
-}
singleton : comparable -> Set comparable
singleton key =
  Set_elm_builtin (Dict.singleton key ())


{-| Insert a value into a set.
-}
insert : comparable -> Set comparable -> Set comparable
insert key (Set_elm_builtin dict) =
  Set_elm_builtin (Dict.insert key () dict)


{-| Remove a value from a set. If the value is not found, no changes are made.
-}
remove : comparable -> Set comparable -> Set comparable
remove key (Set_elm_builtin dict) =
  Set_elm_builtin (Dict.remove key dict)


{-| Determine if a set is empty.
-}
isEmpty : Set a -> Bool
isEmpty (Set_elm_builtin dict) =
  Dict.isEmpty dict


{-| Determine if a value is in a set.
-}
member : comparable -> Set comparable -> Bool
member key (Set_elm_builtin dict) =
  Dict.member key dict


{-| Determine the number of elements in a set.
-}
size : Set a -> Int
size (Set_elm_builtin dict) =
  Dict.size dict


{-| Get the union of two sets. Keep all values.
-}
union : Set comparable -> Set comparable -> Set comparable
union (Set_elm_builtin dict1) (Set_elm_builtin dict2) =
  Set_elm_builtin (Dict.union dict1 dict2)


{-| Get the intersection of two sets. Keeps values that appear in both sets.
-}
intersect : Set comparable -> Set comparable -> Set comparable
intersect (Set_elm_builtin dict1) (Set_elm_builtin dict2) =
  Set_elm_builtin (Dict.intersect dict1 dict2)


{-| Get the difference between the first set and the second. Keeps values
that do not appear in the second set.
-}
diff : Set comparable -> Set comparable -> Set comparable
diff (Set_elm_builtin dict1) (Set_elm_builtin dict2) =
  Set_elm_builtin (Dict.diff dict1 dict2)


{-| Convert a set into a list, sorted from lowest to highest.
-}
toList : Set a -> List a
toList (Set_elm_builtin dict) =
  Dict.keys dict


{-| Convert a list into a set, removing any duplicates.
-}
fromList : List comparable -> Set comparable
fromList list =
  List.foldl insert empty list


{-| Fold over the values in a set, in order from lowest to highest.
-}
foldl : (a -> b -> b) -> b -> Set a -> b
foldl func initialState (Set_elm_builtin dict) =
  Dict.foldl (\key _ state -> func key state) initialState dict


{-| Fold over the values in a set, in order from highest to lowest.
-}
foldr : (comparable -> b -> b) -> b -> Set comparable -> b
foldr func initialState (Set_elm_builtin dict) =
  Dict.foldr (\key _ state -> func key state) initialState dict


{-| Map a function onto a set, creating a new set with no duplicates.
-}
map : (comparable -> comparable2) -> Set comparable -> Set comparable2
map func set =
  fromList (foldl (\x xs -> func x :: xs) [] set)


{-| Filter based on some function. Maybe you have a set of strings that needs
to be a set of numbers:

    import Set exposing (Set)

    strings : Set String
    strings =
      Set.fromList ["000100","090","1","one"]

    numbers : Set Int
    numbers =
      Set.filter String.toInt strings

    -- numbers == Set.fromList [1,90,100]

**Note:** See [`keepIf`](#keepIf) and [`dropIf`](#dropIf) to filter based on a
test like `(\x -> x < 0)` where it just gives a `Bool`.
-}
filter : (comparable1 -> Maybe comparable2) -> Set comparable1 -> Set comparable2
filter func set =
  let
    maybeAdd x ys =
      case func x of
        Nothing ->
          ys

        Just y ->
          y :: ys
  in
  fromList (foldl maybeAdd [] set)


{-| Only keep elements that pass the given test.

    import Set exposing (Set)

    numbers : Set Int
    numbers =
      Set.fromList [-2,-1,0,1,2]

    positives : Set Int
    positives =
      Set.keepIf (\x -> x > 0) numbers

    -- positives == Set.fromList [1,2]
-}
keepIf : (comparable -> Bool) -> Set comparable -> Set comparable
keepIf isGood (Set_elm_builtin dict) =
  Set_elm_builtin (Dict.keepIf (\key _ -> isGood key) dict)


{-| Drop any elements that pass the given test.

    import Set exposing (Set)

    numbers : Set Int
    numbers =
      Set.fromList [-2,-1,0,1,2]

    positives : Set Int
    positives =
      Set.dropIf (\x -> x <= 0) numbers

    -- positives == Set.fromList [1,2]
-}
dropIf : (comparable -> Bool) -> Set comparable -> Set comparable
dropIf isBad (Set_elm_builtin dict) =
  Set_elm_builtin (Dict.dropIf (\key _ -> isBad key) dict)


{-| Create two new sets. The first contains all the elements that passed the
given test, and the second contains all the elements that did not.
-}
partition : (comparable -> Bool) -> Set comparable -> (Set comparable, Set comparable)
partition isGood (Set_elm_builtin dict) =
  let
    (dict1, dict2) =
      Dict.partition (\key _ -> isGood key) dict
  in
    (Set_elm_builtin dict1, Set_elm_builtin dict2)
