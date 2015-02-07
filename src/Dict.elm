module Dict
    ( Dict
    , empty, singleton, insert, update
    , get, remove, member
    , filter
    , partition
    , foldl, foldr, map
    , union, intersect, diff
    , keys, values
    , toList, fromList
    ) where

{-| A dictionary mapping unique keys to values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.

Insert, remove, and query operations all take *O(log n)* time. Dictionary
equality with `(==)` is unreliable and should not be used.

# Build
@docs empty, singleton, insert, update, remove

# Query
@docs member, get

# Combine
@docs union, intersect, diff

# Lists
@docs keys, values, toList, fromList

# Transform
@docs map, foldl, foldr, filter, partition

-}


import Basics exposing (..)
import Maybe exposing (..)
import List exposing (..)
import Native.Debug
import String


-- BBlack and NBlack should only be used during the deletion
-- algorithm. Any other occurrence is a bug and should fail an assert.
type NColor
    = Red
    | Black
    | BBlack  -- Double Black, counts as 2 blacks for the invariant
    | NBlack  -- Negative Black, counts as -1 blacks for the invariant


showNColor : NColor -> String
showNColor c =
  case c of
    Red    -> "Red"
    Black  -> "Black"
    BBlack -> "BBlack"
    NBlack -> "NBlack"


type LeafColor
    = LBlack
    | LBBlack -- Double Black, counts as 2


showLColor : LeafColor -> String
showLColor color =
    case color of
      LBlack  -> "LBlack"
      LBBlack -> "LBBlack"


type Dict k v
    = RBNode NColor k v (Dict k v) (Dict k v)
    | RBEmpty LeafColor


{-| Create an empty dictionary. -}
empty : Dict comparable v
empty = RBEmpty LBlack


min : Dict k v -> (k,v)
min dict =
    case dict of
      RBNode _ key value (RBEmpty LBlack) _ ->
          (key, value)

      RBNode _ _ _ left _ ->
          min left

      RBEmpty LBlack ->
          Native.Debug.crash "(min Empty) is not defined"


max : Dict k v -> (k, v)
max dict =
    case dict of
      RBNode _ key value _ (RBEmpty _) ->
          (key, value)

      RBNode _ _ _ _ right ->
          max right

      RBEmpty _ ->
          Native.Debug.crash "(max Empty) is not defined"


{-| Get the value associated with a key. If the key is not found, return
`Nothing`. This is useful when you are not sure if a key will be in the
dictionary.

    animals = fromList [ ("Tom", Cat), ("Jerry", Mouse) ]

    get "Tom"   animals == Just Cat
    get "Mouse" animals == Just Mouse
    get "Spike" animals == Nothing

-}
get : comparable -> Dict comparable v -> Maybe v
get targetKey dict =
    case dict of
      RBEmpty LBlack ->
          Nothing

      RBNode _ key value left right ->
          case compare targetKey key of
            LT -> get targetKey left
            EQ -> Just value
            GT -> get targetKey right


{-| Determine if a key is in a dictionary. -}
member : comparable -> Dict comparable v -> Bool
member key dict =
    case get key dict of
      Just _ -> True
      Nothing -> False


ensureBlackRoot : Dict k v -> Dict k v
ensureBlackRoot dict =
    case dict of
      RBNode Red key value left right ->
          RBNode Black key value left right

      RBNode Black _ _ _ _ ->
          dict

      RBEmpty LBlack ->
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

showFlag : Flag -> String
showFlag f = case f of
  Insert -> "Insert"
  Remove -> "Remove"
  Same   -> "Same"


{-| Update the value of a dictionary for a specific key with a given function. -}
update : comparable -> (Maybe v -> Maybe v) -> Dict comparable v -> Dict comparable v
update k alter dict = 
  let up dict =
          case dict of
            RBEmpty LBlack ->
                case alter Nothing of
                  Nothing -> (Same, empty)
                  Just v  -> (Insert, RBNode Red k v empty empty)

            RBNode clr key value left right ->
                case compare k key of
                  EQ ->
                    case alter (Just value) of
                      Nothing -> (Remove, rem clr left right)
                      Just newValue ->
                          (Same, RBNode clr key newValue left right)

                  LT ->
                    let (flag, newLeft) = up left in
                    case flag of
                      Same   -> (Same, RBNode clr key value newLeft right)
                      Insert -> (Insert, balance clr key value newLeft right)
                      Remove -> (Remove, bubble clr key value newLeft right)

                  GT ->
                    let (flag, newRight) = up right in
                    case flag of
                      Same   -> (Same, RBNode clr key value left newRight)
                      Insert -> (Insert, balance clr key value left newRight)
                      Remove -> (Remove, bubble clr key value left newRight)

      (flag, updatedDict) = up dict
  in
      case flag of
        Same   -> updatedDict
        Insert -> ensureBlackRoot updatedDict
        Remove -> blacken updatedDict


{-| Create a dictionary with one key-value pair. -}
singleton : comparable -> v -> Dict comparable v
singleton key value =
    insert key value (RBEmpty LBlack)


isBBlack : Dict k v -> Bool
isBBlack dict =
    case dict of
      RBNode BBlack _ _ _ _ -> True
      RBEmpty LBBlack -> True
      _ -> False


moreBlack : NColor -> NColor
moreBlack color =
    case color of
      Black  -> BBlack
      Red    -> Black
      NBlack -> Red
      BBlack -> Native.Debug.crash "Can't make a double black node more black!"


lessBlack : NColor -> NColor
lessBlack color =
    case color of
      BBlack -> Black
      Black  -> Red
      Red    -> NBlack
      NBlack -> Native.Debug.crash "Can't make a negative black node less black!"


lessBlackTree : Dict k v -> Dict k v
lessBlackTree dict =
    case dict of
      RBNode c k v l r -> RBNode (lessBlack c) k v l r
      RBEmpty LBBlack -> RBEmpty LBlack


reportRemBug : String -> NColor -> String -> String -> a
reportRemBug msg c lgot rgot =
  Native.Debug.crash <|
    String.concat
    [ "Internal red-black tree invariant violated, expected "
    , msg, " and got ", showNColor c, "/", lgot, "/", rgot
    , "\nPlease report this bug to <https://github.com/elm-lang/Elm/issues>"
    ]


-- Remove the top node from the tree, may leave behind BBlacks
rem : NColor -> Dict k v -> Dict k v -> Dict k v
rem c l r =
    case (l, r) of
      (RBEmpty _, RBEmpty _) ->
          case c of
            Red   -> RBEmpty LBlack
            Black -> RBEmpty LBBlack

      (RBEmpty cl, RBNode cr k' v' l' r') ->
          case (c, cl, cr) of
            (Black, LBlack, Red) ->
                RBNode Black k' v' l' r'

            _ ->
                reportRemBug "Black/LBlack/Red" c (showLColor cl) (showNColor cr)

      (RBNode cl k' v' l' r', RBEmpty cr) ->
          case (c, cl, cr) of
            (Black, Red, LBlack) ->
                RBNode Black k' v' l' r'

            _ ->
                reportRemBug "Black/Red/LBlack" c (showNColor cl) (showLColor cr)

      -- l and r are both RBNodes
      (RBNode cl kl vl ll rl, RBNode cr kr vr lr rr) ->
          let l = RBNode cl kl vl ll rl
              r = RBNode cr kr vr lr rr
              (k, v) = max l
              l'     = remove_max cl kl vl ll rl
          in
              bubble c k v l' r


-- Kills a BBlack or moves it upward, may leave behind NBlack
bubble : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
bubble c k v l r =
    if isBBlack l || isBBlack r
        then balance (moreBlack c) k v (lessBlackTree l) (lessBlackTree r)
        else RBNode c k v l r


-- Removes rightmost node, may leave root as BBlack
remove_max : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
remove_max c k v l r =
    case r of
      RBEmpty _ ->
          rem c l r

      RBNode cr kr vr lr rr ->
          bubble c k v l (remove_max cr kr vr lr rr)


-- generalized tree balancing act
balance : NColor -> k -> v -> Dict k v -> Dict k v -> Dict k v
balance c k v l r =
    balance_node (RBNode c k v l r)


blackish : Dict k v -> Bool
blackish t =
    case t of
      RBNode c _ _ _ _ -> c == Black || c == BBlack
      RBEmpty _        -> True


balance_node : Dict k v -> Dict k v
balance_node t = 
  let assemble col xk xv yk yv zk zv a b c d = 
        RBNode (lessBlack col) yk yv (RBNode Black xk xv a b) (RBNode Black zk zv c d)
  in 
   if blackish t
   then case t of
     RBNode col zk zv (RBNode Red yk yv (RBNode Red xk xv a b) c) d ->
       assemble col xk xv yk yv zk zv a b c d
     RBNode col zk zv (RBNode Red xk xv a (RBNode Red yk yv b c)) d ->
       assemble col xk xv yk yv zk zv a b c d
     RBNode col xk xv a (RBNode Red zk zv (RBNode Red yk yv b c) d) ->
       assemble col xk xv yk yv zk zv a b c d
     RBNode col xk xv a (RBNode Red yk yv b (RBNode Red zk zv c d)) ->
       assemble col xk xv yk yv zk zv a b c d

     RBNode BBlack xk xv a (RBNode NBlack zk zv (RBNode Black yk yv b c) d) ->
       case d of
         (RBNode Black _ _ _ _) -> 
           RBNode Black yk yv (RBNode Black xk xv a b) (balance Black zk zv c (redden d))
         _ -> t

     RBNode BBlack zk zv (RBNode NBlack xk xv a (RBNode Black yk yv b c)) d ->
       case a of
         (RBNode Black _ _ _ _) -> 
           RBNode Black yk yv (balance Black xk xv (redden a) b) (RBNode Black zk zv c d)
         _ -> t
     _ -> t
   else t


-- make the top node black
blacken : Dict k v -> Dict k v
blacken t =
    case t of
      RBEmpty _ -> RBEmpty LBlack
      RBNode _ k v l r -> RBNode Black k v l r


-- make the top node red
redden : Dict k v -> Dict k v
redden t =
    case t of
      RBEmpty _ -> Native.Debug.crash "can't make a Leaf red"
      RBNode _ k v l r -> RBNode Red k v l r


{-| Apply a function to all values in a dictionary. -}
map : (comparable -> a -> b) -> Dict comparable a -> Dict comparable b
map f dict =
    case dict of
      RBEmpty LBlack ->
          RBEmpty LBlack

      RBNode clr key value left right ->
          RBNode clr key (f key value) (map f left) (map f right)


{-| Fold over the key-value pairs in a dictionary, in order from lowest
key to highest key. -}
foldl : (comparable -> v -> b -> b) -> b -> Dict comparable v -> b
foldl f acc dict =
    case dict of
      RBEmpty LBlack -> acc

      RBNode _ key value left right ->
          foldl f (f key value (foldl f acc left)) right


{-| Fold over the key-value pairs in a dictionary, in order from highest
key to lowest key. -}
foldr : (comparable -> v -> b -> b) -> b -> Dict comparable v -> b
foldr f acc t =
    case t of
      RBEmpty LBlack -> acc

      RBNode _ key value left right ->
          foldr f (f key value (foldr f acc right)) left


{-| Combine two dictionaries. If there is a collision, preference is given
to the first dictionary. -}
union : Dict comparable v -> Dict comparable v -> Dict comparable v
union t1 t2 =
    foldl insert t2 t1


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary. -}
intersect : Dict comparable v -> Dict comparable v -> Dict comparable v
intersect t1 t2 =
    filter (\k _ -> k `member` t2) t1


{-| Keep a key-value pair when its key does not appear in the second dictionary.
Preference is given to the first dictionary. -}
diff : Dict comparable v -> Dict comparable v -> Dict comparable v
diff t1 t2 =
    foldl (\k v t -> remove k t) t1 t2


{-| Get all of the keys in a dictionary. -}
keys : Dict comparable v -> List comparable
keys dict =
    foldr (\key value keyList -> key :: keyList) [] dict


{-| Get all of the values in a dictionary. -}
values : Dict comparable v -> List v
values dict =
    foldr (\key value valueList -> value :: valueList) [] dict


{-| Convert a dictionary into an association list of key-value pairs. -}
toList : Dict comparable v -> List (comparable,v)
toList dict =
    foldr (\key value list -> (key,value) :: list) [] dict


{-| Convert an association list into a dictionary. -}
fromList : List (comparable,v) -> Dict comparable v
fromList assocs =
    List.foldl (\(key,value) dict -> insert key value dict) empty assocs


{-| Keep a key-value pair when it satisfies a predicate. -}
filter : (comparable -> v -> Bool) -> Dict comparable v -> Dict comparable v
filter predicate dictionary =
    let add key value dict =
            if predicate key value
                then insert key value dict
                else dict
    in
        foldl add empty dictionary


{-| Partition a dictionary according to a predicate. The first dictionary
contains all key-value pairs which satisfy the predicate, and the second
contains the rest.
-}
partition : (comparable -> v -> Bool) -> Dict comparable v -> (Dict comparable v, Dict comparable v)
partition predicate dict =
    let add key value (t1, t2) =
            if predicate key value
                then (insert key value t1, t2)
                else (t1, insert key value t2)
    in
        foldl add (empty, empty) dict
