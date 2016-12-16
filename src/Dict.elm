module Dict exposing
  ( Dict
  , empty, singleton, insert, update
  , isEmpty, get, remove, member, size
  , filter
  , partition
  , foldl, foldr, map
  , union, intersect, diff, merge
  , keys, values
  , toList, fromList
  )

{-| A dictionary mapping unique keys to values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.

Insert, remove, and query operations all take *O(log n)* time.

# Dictionaries
@docs Dict

# Build
@docs empty, singleton, insert, update, remove

# Query
@docs isEmpty, member, get, size

# Lists
@docs keys, values, toList, fromList

# Transform
@docs map, foldl, foldr, filter, partition

# Combine
@docs union, intersect, diff, merge

-}


import Basics exposing (..)
import Maybe exposing (..)
import List exposing (..)
import Native.Debug
import String



-- DICTIONARIES


-- BBlack and NBlack should only be used during the deletion
-- algorithm. Any other occurrence is a bug and should fail an assert.
type NColor
    = Red
    | Black
    | BBlack  -- Double Black, counts as 2 blacks for the invariant
    | NBlack  -- Negative Black, counts as -1 blacks for the invariant


type LeafColor
    = LBlack
    | LBBlack -- Double Black, counts as 2


{-| A dictionary of keys and values. So a `(Dict String User)` is a dictionary
that lets you look up a `String` (such as user names) and find the associated
`User`.
-}
type Dict k v
    = RBNode_elm_builtin NColor k v (Dict k v) (Dict k v)
    | RBEmpty_elm_builtin LeafColor


{-| Create an empty dictionary. -}
empty : Dict k v
empty =
  RBEmpty_elm_builtin LBlack


maxWithDefault : k -> v -> Dict k v -> (k, v)
maxWithDefault k v r =
  case r of
    RBEmpty_elm_builtin _ ->
      (k, v)

    RBNode_elm_builtin _ kr vr _ rr ->
      maxWithDefault kr vr rr


{-| Get the value associated with a key. If the key is not found, return
`Nothing`. This is useful when you are not sure if a key will be in the
dictionary.

    animals = fromList [ ("Tom", Cat), ("Jerry", Mouse) ]

    get "Tom"   animals == Just Cat
    get "Jerry" animals == Just Mouse
    get "Spike" animals == Nothing

-}
get : comparable -> Dict comparable v -> Maybe v
get targetKey dict =
  case dict of
    RBEmpty_elm_builtin _ ->
      Nothing

    RBNode_elm_builtin _ key value left right ->
      case compare targetKey key of
        LT ->
          get targetKey left

        EQ ->
          Just value

        GT ->
          get targetKey right


{-| Determine if a key is in a dictionary. -}
member : comparable -> Dict comparable v -> Bool
member key dict =
  case get key dict of
    Just _ ->
      True

    Nothing ->
      False


{-| Determine the number of key-value pairs in the dictionary. -}
size : Dict k v -> Int
size dict =
  sizeHelp 0 dict


sizeHelp : Int -> Dict k v -> Int
sizeHelp n dict =
  case dict of
    RBEmpty_elm_builtin _ ->
      n

    RBNode_elm_builtin _ _ _ left right ->
      sizeHelp (sizeHelp (n+1) right) left


{-| Determine if a dictionary is empty.

    isEmpty empty == True
-}
isEmpty : Dict k v -> Bool
isEmpty dict =
  dict == empty


{- The actual pattern match here is somewhat lax. If it is given invalid input,
it will do the wrong thing. The expected behavior is:

  red node => black node
  black node => same
  bblack node => xxx
  nblack node => xxx

  black leaf => same
  bblack leaf => xxx
-}
ensureBlackRoot : Dict k v -> Dict k v
ensureBlackRoot dict =
  case dict of
    RBNode_elm_builtin Red key value left right ->
      RBNode_elm_builtin Black key value left right

    _ ->
      dict


{-| Insert a key-value pair into a dictionary. Replaces value when there is
a collision. -}
insert : comparable -> v -> Dict comparable v -> Dict comparable v
insert key value dict =
  update key (always (Just value)) dict


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made. -}
remove : comparable -> Dict comparable v -> Dict comparable v
remove key dict =
  update key (always Nothing) dict


type Flag = Insert | Remove | Same


{-| Update the value of a dictionary for a specific key with a given function. -}
update : comparable -> (Maybe v -> Maybe v) -> Dict comparable v -> Dict comparable v
update k alter dict =
  let
    up dict =
      case dict of
        -- expecting only black nodes, never double black nodes here
        RBEmpty_elm_builtin _ ->
          case alter Nothing of
            Nothing ->
              (Same, empty)

            Just v  ->
              (Insert, RBNode_elm_builtin Red k v empty empty)

        RBNode_elm_builtin clr key value left right ->
          case compare k key of
            EQ ->
              case alter (Just value) of
                Nothing ->
                  (Remove, rem clr left right)

                Just newValue ->
                  (Same, RBNode_elm_builtin clr key newValue left right)

            LT ->
              let (flag, newLeft) = up left in
              case flag of
                Same ->
                  (Same, RBNode_elm_builtin clr key value newLeft right)

                Insert ->
                  (Insert, balance clr key value newLeft right)

                Remove ->
                  (Remove, bubble clr key value newLeft right)

            GT ->
              let (flag, newRight) = up right in
              case flag of
                Same ->
                  (Same, RBNode_elm_builtin clr key value left newRight)

                Insert ->
                  (Insert, balance clr key value left newRight)

                Remove ->
                  (Remove, bubble clr key value left newRight)

    (flag, updatedDict) =
      up dict
  in
    case flag of
      Same ->
        updatedDict

      Insert ->
        ensureBlackRoot updatedDict

      Remove ->
        blacken updatedDict


{-| Create a dictionary with one key-value pair. -}
singleton : comparable -> v -> Dict comparable v
singleton key value =
  insert key value empty



-- HELPERS


isBBlack : Dict k v -> Bool
isBBlack dict =
  case dict of
    RBNode_elm_builtin BBlack _ _ _ _ ->
      True

    RBEmpty_elm_builtin LBBlack ->
      True

    _ ->
      False


moreBlack : NColor -> NColor
moreBlack color =
  case color of
    Black ->
      BBlack

    Red ->
      Black

    NBlack ->
      Red

    BBlack ->
      Native.Debug.crash "Can't make a double black node more black!"


lessBlack : NColor -> NColor
lessBlack color =
  case color of
    BBlack ->
      Black

    Black ->
      Red

    Red ->
      NBlack

    NBlack ->
      Native.Debug.crash "Can't make a negative black node less black!"


{- The actual pattern match here is somewhat lax. If it is given invalid input,
it will do the wrong thing. The expected behavior is:

  node => less black node

  bblack leaf => black leaf
  black leaf => xxx
-}
lessBlackTree : Dict k v -> Dict k v
lessBlackTree dict =
  case dict of
    RBNode_elm_builtin c k v l r ->
      RBNode_elm_builtin (lessBlack c) k v l r

    RBEmpty_elm_builtin _ ->
      RBEmpty_elm_builtin LBlack


reportRemBug : String -> NColor -> String -> String -> a
reportRemBug msg c lgot rgot =
  Native.Debug.crash <|
    String.concat
    [ "Internal red-black tree invariant violated, expected "
    , msg, " and got ", toString c, "/", lgot, "/", rgot
    , "\nPlease report this bug to <https://github.com/elm-lang/core/issues>"
    ]


-- Remove the top node from the tree, may leave behind BBlacks
rem : NColor -> Dict k v -> Dict k v -> Dict k v
rem color left right =
  case (left, right) of
    (RBEmpty_elm_builtin _, RBEmpty_elm_builtin _) ->
      case color of
        Red ->
          RBEmpty_elm_builtin LBlack

        Black ->
          RBEmpty_elm_builtin LBBlack

        _ ->
          Native.Debug.crash "cannot have bblack or nblack nodes at this point"

    (RBEmpty_elm_builtin cl, RBNode_elm_builtin cr k v l r) ->
      case (color, cl, cr) of
        (Black, LBlack, Red) ->
          RBNode_elm_builtin Black k v l r

        _ ->
          reportRemBug "Black/LBlack/Red" color (toString cl) (toString cr)

    (RBNode_elm_builtin cl k v l r, RBEmpty_elm_builtin cr) ->
      case (color, cl, cr) of
        (Black, Red, LBlack) ->
          RBNode_elm_builtin Black k v l r

        _ ->
          reportRemBug "Black/Red/LBlack" color (toString cl) (toString cr)

    -- l and r are both RBNodes
    (RBNode_elm_builtin cl kl vl ll rl, RBNode_elm_builtin _ _ _ _ _) ->
      let
        (k, v) =
          maxWithDefault kl vl rl

        newLeft =
          removeMax cl kl vl ll rl
      in
        bubble color k v newLeft right


-- Kills a BBlack or moves it upward, may leave behind NBlack
bubble : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
bubble c k v l r =
  if isBBlack l || isBBlack r then
    balance (moreBlack c) k v (lessBlackTree l) (lessBlackTree r)

  else
    RBNode_elm_builtin c k v l r


-- Removes rightmost node, may leave root as BBlack
removeMax : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
removeMax c k v l r =
  case r of
    RBEmpty_elm_builtin _ ->
      rem c l r

    RBNode_elm_builtin cr kr vr lr rr ->
      bubble c k v l (removeMax cr kr vr lr rr)


-- generalized tree balancing act
balance : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
balance c k v l r =
  let
    tree =
      RBNode_elm_builtin c k v l r
  in
    if blackish tree then
      balanceHelp tree

    else
      tree


blackish : Dict k v -> Bool
blackish t =
  case t of
    RBNode_elm_builtin c _ _ _ _ ->
      c == Black || c == BBlack

    RBEmpty_elm_builtin _ ->
      True


balanceHelp : Dict k v -> Dict k v
balanceHelp tree =
  case tree of
    -- double red: left, left
    RBNode_elm_builtin col zk zv (RBNode_elm_builtin Red yk yv (RBNode_elm_builtin Red xk xv a b) c) d ->
      balancedTree col xk xv yk yv zk zv a b c d

    -- double red: left, right
    RBNode_elm_builtin col zk zv (RBNode_elm_builtin Red xk xv a (RBNode_elm_builtin Red yk yv b c)) d ->
      balancedTree col xk xv yk yv zk zv a b c d

    -- double red: right, left
    RBNode_elm_builtin col xk xv a (RBNode_elm_builtin Red zk zv (RBNode_elm_builtin Red yk yv b c) d) ->
      balancedTree col xk xv yk yv zk zv a b c d

    -- double red: right, right
    RBNode_elm_builtin col xk xv a (RBNode_elm_builtin Red yk yv b (RBNode_elm_builtin Red zk zv c d)) ->
      balancedTree col xk xv yk yv zk zv a b c d

    -- handle double blacks
    RBNode_elm_builtin BBlack xk xv a (RBNode_elm_builtin NBlack zk zv (RBNode_elm_builtin Black yk yv b c) (RBNode_elm_builtin Black _ _ _ _ as d)) ->
      RBNode_elm_builtin Black yk yv (RBNode_elm_builtin Black xk xv a b) (balance Black zk zv c (redden d))

    RBNode_elm_builtin BBlack zk zv (RBNode_elm_builtin NBlack xk xv (RBNode_elm_builtin Black _ _ _ _ as a) (RBNode_elm_builtin Black yk yv b c)) d ->
      RBNode_elm_builtin Black yk yv (balance Black xk xv (redden a) b) (RBNode_elm_builtin Black zk zv c d)

    _ ->
      tree


balancedTree : NColor -> k -> v -> k -> v -> k -> v -> Dict k v -> Dict k v -> Dict k v -> Dict k v -> Dict k v
balancedTree col xk xv yk yv zk zv a b c d =
  RBNode_elm_builtin
    (lessBlack col)
    yk
    yv
    (RBNode_elm_builtin Black xk xv a b)
    (RBNode_elm_builtin Black zk zv c d)


-- make the top node black
blacken : Dict k v -> Dict k v
blacken t =
  case t of
    RBEmpty_elm_builtin _ ->
      RBEmpty_elm_builtin LBlack

    RBNode_elm_builtin _ k v l r ->
      RBNode_elm_builtin Black k v l r


-- make the top node red
redden : Dict k v -> Dict k v
redden t =
  case t of
    RBEmpty_elm_builtin _ ->
      Native.Debug.crash "can't make a Leaf red"

    RBNode_elm_builtin _ k v l r ->
      RBNode_elm_builtin Red k v l r



-- COMBINE


{-| Combine two dictionaries. If there is a collision, preference is given
to the first dictionary.
-}
union : Dict comparable v -> Dict comparable v -> Dict comparable v
union t1 t2 =
  foldl insert t2 t1


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict comparable v -> Dict comparable v -> Dict comparable v
intersect t1 t2 =
  filter (\k _ -> member k t2) t1


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict comparable v -> Dict comparable v -> Dict comparable v
diff t1 t2 =
  foldl (\k v t -> remove k t) t1 t2


{-| The most general way of combining two dictionaries. You provide three
accumulators for when a given key appears:

  1. Only in the left dictionary.
  2. In both dictionaries.
  3. Only in the right dictionary.

You then traverse all the keys from lowest to highest, building up whatever
you want.
-}
merge
  :  (comparable -> a -> result -> result)
  -> (comparable -> a -> b -> result -> result)
  -> (comparable -> b -> result -> result)
  -> Dict comparable a
  -> Dict comparable b
  -> result
  -> result
merge leftStep bothStep rightStep leftDict rightDict initialResult =
  let
    stepState rKey rValue (list, result) =
      case list of
        [] ->
          (list, rightStep rKey rValue result)

        (lKey, lValue) :: rest ->
          if lKey < rKey then
            stepState rKey rValue (rest, leftStep lKey lValue result)

          else if lKey > rKey then
            (list, rightStep rKey rValue result)

          else
            (rest, bothStep lKey lValue rValue result)

    (leftovers, intermediateResult) =
      foldl stepState (toList leftDict, initialResult) rightDict
  in
    List.foldl (\(k,v) result -> leftStep k v result) intermediateResult leftovers



-- TRANSFORM


{-| Apply a function to all values in a dictionary.
-}
map : (comparable -> a -> b) -> Dict comparable a -> Dict comparable b
map f dict =
  case dict of
    RBEmpty_elm_builtin _ ->
      RBEmpty_elm_builtin LBlack

    RBNode_elm_builtin clr key value left right ->
      RBNode_elm_builtin clr key (f key value) (map f left) (map f right)


{-| Fold over the key-value pairs in a dictionary, in order from lowest
key to highest key.
-}
foldl : (comparable -> v -> b -> b) -> b -> Dict comparable v -> b
foldl f acc dict =
  case dict of
    RBEmpty_elm_builtin _ ->
      acc

    RBNode_elm_builtin _ key value left right ->
      foldl f (f key value (foldl f acc left)) right


{-| Fold over the key-value pairs in a dictionary, in order from highest
key to lowest key.
-}
foldr : (comparable -> v -> b -> b) -> b -> Dict comparable v -> b
foldr f acc t =
  case t of
    RBEmpty_elm_builtin _ ->
      acc

    RBNode_elm_builtin _ key value left right ->
      foldr f (f key value (foldr f acc right)) left


{-| Keep a key-value pair when it satisfies a predicate. -}
filter : (comparable -> v -> Bool) -> Dict comparable v -> Dict comparable v
filter predicate dictionary =
  let
    add key value dict =
      if predicate key value then
        insert key value dict

      else
        dict
  in
    foldl add empty dictionary


{-| Partition a dictionary according to a predicate. The first dictionary
contains all key-value pairs which satisfy the predicate, and the second
contains the rest.
-}
partition : (comparable -> v -> Bool) -> Dict comparable v -> (Dict comparable v, Dict comparable v)
partition predicate dict =
  let
    add key value (t1, t2) =
      if predicate key value then
        (insert key value t1, t2)

      else
        (t1, insert key value t2)
  in
    foldl add (empty, empty) dict



-- LISTS


{-| Get all of the keys in a dictionary, sorted from lowest to highest.

    keys (fromList [(0,"Alice"),(1,"Bob")]) == [0,1]
-}
keys : Dict comparable v -> List comparable
keys dict =
  foldr (\key value keyList -> key :: keyList) [] dict


{-| Get all of the values in a dictionary, in the order of their keys.

    values (fromList [(0,"Alice"),(1,"Bob")]) == ["Alice", "Bob"]
-}
values : Dict comparable v -> List v
values dict =
  foldr (\key value valueList -> value :: valueList) [] dict


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys. -}
toList : Dict comparable v -> List (comparable,v)
toList dict =
  foldr (\key value list -> (key,value) :: list) [] dict


{-| Convert an association list into a dictionary. -}
fromList : List (comparable,v) -> Dict comparable v
fromList assocs =
  List.foldl (\(key,value) dict -> insert key value dict) empty assocs
