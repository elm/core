module Set exposing
  ( Set
  , empty, singleton, insert, remove
  , isEmpty, member, size
  , foldl, foldr, map
  , filter, partition
  , union, intersect, diff
  , toList, fromList
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
@docs map, foldl, foldr, filter, partition

-}

import Basics exposing (Bool, Int, (<|))
import Dict as Dict
import List as List


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
  Set_elm_builtin <|
    Dict.singleton key ()


{-| Insert a value into a set.
-}
insert : comparable -> Set comparable -> Set comparable
insert key (Set_elm_builtin dict) =
  Set_elm_builtin <|
    Dict.insert key () dict


{-| Remove a value from a set. If the value is not found, no changes are made.
-}
remove : comparable -> Set comparable -> Set comparable
remove key (Set_elm_builtin dict) =
  Set_elm_builtin <|
    Dict.remove key dict


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
  Set_elm_builtin <|
    Dict.union dict1 dict2


{-| Get the intersection of two sets. Keeps values that appear in both sets.
-}
intersect : Set comparable -> Set comparable -> Set comparable
intersect (Set_elm_builtin dict1) (Set_elm_builtin dict2) =
  Set_elm_builtin <|
    Dict.intersect dict1 dict2


{-| Get the difference between the first set and the second. Keeps values
that do not appear in the second set.
-}
diff : Set comparable -> Set comparable -> Set comparable
diff (Set_elm_builtin dict1) (Set_elm_builtin dict2) =
  Set_elm_builtin <|
    Dict.diff dict1 dict2


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
  fromList (List.map func (toList set))


{-| Create a new set consisting only of elements which satisfy a predicate.
-}
filter : (comparable -> Bool) -> Set comparable -> Set comparable
filter isGood (Set_elm_builtin dict) =
  Set_elm_builtin <|
    Dict.filter (\key _ -> isGood key) dict


{-| Create two new sets; the first consisting of elements which satisfy a
predicate, the second consisting of elements which do not.
-}
partition : (comparable -> Bool) -> Set comparable -> (Set comparable, Set comparable)
partition isGood (Set_elm_builtin dict) =
  let
    (dict1, dict2) =
      Dict.partition (\key _ -> isGood key) dict
  in
    (Set_elm_builtin dict1, Set_elm_builtin dict2)
