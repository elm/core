module Dict
    exposing
        ( Dict
        , empty
        , singleton
        , insert
        , update
        , isEmpty
        , get
        , remove
        , member
        , size
        , filter
        , partition
        , foldl
        , foldr
        , map
        , union
        , intersect
        , diff
        , merge
        , keys
        , values
        , toList
        , fromList
          -- , validateInvariants
        )

{-| A dictionary mapping unique keys to values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.

Insert, remove, and query operations all take *O(log n)* time.


# Dictionaries

@docs Dict


# Build

@docs empty, singleton, insert, remove, update


# Query

@docs isEmpty, size, get, member


# Transform

@docs map, foldl, foldr, filter, partition


# Combine

@docs union, intersect, diff, merge


# Lists

@docs keys, values, toList, fromList

-}

import Basics exposing (..)
import Debug
import Maybe exposing (..)
import List exposing (..)


{-
   The following is an implementation of Left-Leaning Red Black Trees (LLRB Tree).
   More information about this implementation can be found at the following links:

   http://www.cs.princeton.edu/~rs/talks/LLRB/LLRB.pdf
   http://www.cs.princeton.edu/~rs/talks/LLRB/RedBlack.pdf

   The short of it is, that in addition to the regular rules for RB trees, the following rule
   applies: No right references can be red.
-}


{-| A dictionary of keys and values. So a `(Dict String User)` is a dictionary
that lets you look up a `String` (such as user names) and find the associated
`User`.
-}
type Dict key value
    = Leaf
    | Node Color key value (Dict key value) (Dict key value)


{-| The color of a Node. Leafs are considered black.
-}
type Color
    = Black
    | Red


{-| Create an empty dictionary.
-}
empty : Dict k v
empty =
    Leaf


{-| Determine if a dictionary is empty.
isEmpty empty == True
-}
isEmpty : Dict k v -> Bool
isEmpty dict =
    dict == empty


{-| Create a dictionary with one key-value pair.
-}
singleton : comparable -> v -> Dict comparable v
singleton key value =
    -- Root is always black
    Node Black key value Leaf Leaf


{-| Determine the number of key-value pairs in the dictionary.
-}
size : Dict k v -> Int
size dict =
    sizeHelp 0 dict


sizeHelp : Int -> Dict k v -> Int
sizeHelp n dict =
    case dict of
        Leaf ->
            n

        Node _ _ _ left right ->
            sizeHelp (sizeHelp (n + 1) right) left


{-| Get the value associated with a key. If the key is not found, return
`Nothing`. This is useful when you are not sure if a key will be in the
dictionary.

    animals = fromList [ ("Tom", Cat), ("Jerry", Mouse) ]
    get "Tom" animals == Just Cat
    get "Jerry" animals == Just Mouse
    get "Spike" animals == Nothing

-}
get : comparable -> Dict comparable v -> Maybe v
get targetKey dict =
    case dict of
        Leaf ->
            Nothing

        Node _ key value left right ->
            case compare targetKey key of
                LT ->
                    get targetKey left

                EQ ->
                    Just value

                GT ->
                    get targetKey right


{-| Determine if a key is in a dictionary.
-}
member : comparable -> Dict comparable v -> Bool
member key dict =
    case get key dict of
        Just _ ->
            True

        Nothing ->
            False


{-| Insert a key-value pair into a dictionary. Replaces value when there is
a collision.
-}
insert : comparable -> v -> Dict comparable v -> Dict comparable v
insert key value dict =
    case insertHelp key value dict of
        Node Red k v l r ->
            -- Root is always black
            Node Black k v l r

        x ->
            x


insertHelp : comparable -> v -> Dict comparable v -> Dict comparable v
insertHelp key value dict =
    case dict of
        Leaf ->
            -- New nodes are always red. If it violates the rules, it will be fixed
            -- when balancing.
            Node Red key value Leaf Leaf

        Node nColor nKey nValue nLeft nRight ->
            case compare key nKey of
                LT ->
                    balance nColor nKey nValue (insertHelp key value nLeft) nRight

                EQ ->
                    Node nColor nKey value nLeft nRight

                GT ->
                    balance nColor nKey nValue nLeft (insertHelp key value nRight)


balance : Color -> k -> v -> Dict k v -> Dict k v -> Dict k v
balance color key value left right =
    case right of
        Node Red rK rV rLeft rRight ->
            case left of
                Node Red lK lV lLeft lRight ->
                    Node
                        Red
                        key
                        value
                        (Node Black lK lV lLeft lRight)
                        (Node Black rK rV rLeft rRight)

                _ ->
                    Node color rK rV (Node Red key value left rLeft) rRight

        _ ->
            case left of
                Node Red lK lV (Node Red llK llV llLeft llRight) lRight ->
                    Node
                        Red
                        lK
                        lV
                        (Node Black llK llV llLeft llRight)
                        (Node Black key value lRight right)

                _ ->
                    Node color key value left right


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made.
-}
remove : comparable -> Dict comparable v -> Dict comparable v
remove targetKey dict =
    case removeHelp targetKey dict of
        Node Red k v l r ->
            -- Root is always black
            Node Black k v l r

        x ->
            x


{-| The easiest thing to remove from the tree, is a red node. However, when searching for the
node to remove, we have no way of knowing if it will be red or not. This remove implementation
makes sure that the bottom node is red by moving red colors down the tree through rotation
and color flips. Any violations this will cause, can easily be fixed by balancing on the way
up again.
-}
removeHelp : comparable -> Dict comparable v -> Dict comparable v
removeHelp targetKey dict =
    case dict of
        Leaf ->
            Leaf

        Node color key value left right ->
            if targetKey < key then
                case left of
                    Node Black _ _ lLeft _ ->
                        case lLeft of
                            Node Red _ _ _ _ ->
                                Node color key value (removeHelp targetKey left) right

                            _ ->
                                case moveRedLeft dict of
                                    Node color key value left right ->
                                        balance color key value (removeHelp targetKey left) right

                                    Leaf ->
                                        Leaf

                    _ ->
                        Node color key value (removeHelp targetKey left) right
            else
                removeHelpEQGT targetKey (removeHelpPrepEQGT targetKey dict color key value left right)


removeHelpPrepEQGT :
    comparable
    -> Dict comparable v
    -> Color
    -> comparable
    -> v
    -> Dict comparable v
    -> Dict comparable v
    -> Dict comparable v
removeHelpPrepEQGT targetKey dict color key value left right =
    case left of
        Node Red lK lV lLeft lRight ->
            Node
                color
                lK
                lV
                lLeft
                (Node Red key value lRight right)

        _ ->
            case right of
                Node Black _ _ (Node Black _ _ _ _) _ ->
                    moveRedRight dict

                Node Black _ _ Leaf _ ->
                    moveRedRight dict

                _ ->
                    dict


{-| When we find the node we are looking for, we can remove by replacing the key-value
pair with the key-value pair of the left-most node on the right side (the closest pair).
-}
removeHelpEQGT : comparable -> Dict comparable v -> Dict comparable v
removeHelpEQGT targetKey dict =
    case dict of
        Node color key value left right ->
            if targetKey == key then
                case getMin right of
                    Node _ minKey minValue _ _ ->
                        balance color minKey minValue left (removeMin right)

                    Leaf ->
                        Leaf
            else
                balance color key value left (removeHelp targetKey right)

        Leaf ->
            Leaf


getMin : Dict k v -> Dict k v
getMin dict =
    case dict of
        Node _ _ _ ((Node _ _ _ _ _) as left) _ ->
            getMin left

        _ ->
            dict


removeMin : Dict k v -> Dict k v
removeMin dict =
    case dict of
        Node color key value ((Node lColor _ _ lLeft _) as left) right ->
            case lColor of
                Black ->
                    case lLeft of
                        Node Red _ _ _ _ ->
                            Node color key value (removeMin left) right

                        _ ->
                            case moveRedLeft dict of
                                Node color key value left right ->
                                    balance color key value (removeMin left) right

                                Leaf ->
                                    Leaf

                _ ->
                    Node color key value (removeMin left) right

        _ ->
            Leaf


moveRedLeft : Dict k v -> Dict k v
moveRedLeft dict =
    case dict of
        Node clr k v (Node lClr lK lV lLeft lRight) (Node rClr rK rV ((Node Red rlK rlV rlL rlR) as rLeft) rRight) ->
            Node
                Red
                rlK
                rlV
                (Node Black k v (Node Red lK lV lLeft lRight) rlL)
                (Node Black rK rV rlR rRight)

        Node clr k v (Node lClr lK lV lLeft lRight) (Node rClr rK rV rLeft rRight) ->
            case clr of
                Black ->
                    Node
                        Black
                        k
                        v
                        (Node Red lK lV lLeft lRight)
                        (Node Red rK rV rLeft rRight)

                Red ->
                    Node
                        Black
                        k
                        v
                        (Node Red lK lV lLeft lRight)
                        (Node Red rK rV rLeft rRight)

        _ ->
            dict


moveRedRight : Dict k v -> Dict k v
moveRedRight dict =
    case dict of
        Node clr k v (Node lClr lK lV (Node Red llK llV llLeft llRight) lRight) (Node rClr rK rV rLeft rRight) ->
            Node
                Red
                lK
                lV
                (Node Black llK llV llLeft llRight)
                (Node Black k v lRight (Node Red rK rV rLeft rRight))

        Node clr k v (Node lClr lK lV lLeft lRight) (Node rClr rK rV rLeft rRight) ->
            case clr of
                Black ->
                    Node
                        Black
                        k
                        v
                        (Node Red lK lV lLeft lRight)
                        (Node Red rK rV rLeft rRight)

                Red ->
                    Node
                        Black
                        k
                        v
                        (Node Red lK lV lLeft lRight)
                        (Node Red rK rV rLeft rRight)

        _ ->
            dict


{-| Update the value of a dictionary for a specific key with a given function.
The given function gets the current value as a parameter and its return value
determines if the value is updated or removed. New key-value pairs can be
inserted too.
-}
update : comparable -> (Maybe v -> Maybe v) -> Dict comparable v -> Dict comparable v
update key alter dict =
    case alter (get key dict) of
        Nothing ->
            remove key dict

        Just value ->
            insert key value dict



-- TRANSFORM


{-| Apply a function to all values in a dictionary.
-}
map : (k -> a -> b) -> Dict k a -> Dict k b
map f dict =
    case dict of
        Leaf ->
            Leaf

        Node color key value left right ->
            Node color key (f key value) (map f left) (map f right)


{-| Fold over the key-value pairs in a dictionary, in order from lowest
key to highest key.
-}
foldl : (k -> v -> b -> b) -> b -> Dict k v -> b
foldl f acc dict =
    case dict of
        Leaf ->
            acc

        Node _ key value left right ->
            foldl f (f key value (foldl f acc left)) right


{-| Fold over the key-value pairs in a dictionary, in order from highest
key to lowest key.
-}
foldr : (k -> v -> b -> b) -> b -> Dict k v -> b
foldr f acc dict =
    case dict of
        Leaf ->
            acc

        Node _ key value left right ->
            foldr f (f key value (foldr f acc right)) left


{-| Keep a key-value pair when it satisfies a predicate.
-}
filter : (comparable -> v -> Bool) -> Dict comparable v -> Dict comparable v
filter predicate dict =
    let
        helper key value acc =
            if predicate key value then
                insert key value acc
            else
                acc
    in
        foldl helper empty dict


{-| Partition a dictionary according to a predicate. The first dictionary
contains all key-value pairs which satisfy the predicate, and the second
contains the rest.
-}
partition : (comparable -> v -> Bool) -> Dict comparable v -> ( Dict comparable v, Dict comparable v )
partition predicate dict =
    let
        helper key value ( trues, falses ) =
            if predicate key value then
                ( insert key value trues, falses )
            else
                ( trues, insert key value falses )
    in
        foldl helper ( empty, empty ) dict



-- COMBINE


{-| Combine two dictionaries. If there is a collision, preference is given
to the first dictionary.
-}
union : Dict comparable v -> Dict comparable v -> Dict comparable v
union left right =
    foldl insert right left


{-| Keep a key-value pair when its key appears in the second dictionary.
Preference is given to values in the first dictionary.
-}
intersect : Dict comparable v -> Dict comparable v -> Dict comparable v
intersect left right =
    filter (\k _ -> member k right) left


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff : Dict comparable v -> Dict comparable v -> Dict comparable v
diff left right =
    foldl (\k v t -> remove k t) left right


{-| The most general way of combining two dictionaries. You provide three
accumulators for when a given key appears:

1.  Only in the left dictionary.
2.  In both dictionaries.
3.  Only in the right dictionary.
    You then traverse all the keys from lowest to highest, building up whatever
    you want.

-}
merge :
    (comparable -> a -> result -> result)
    -> (comparable -> a -> b -> result -> result)
    -> (comparable -> b -> result -> result)
    -> Dict comparable a
    -> Dict comparable b
    -> result
    -> result
merge leftStep bothStep rightStep leftDict rightDict initialResult =
    let
        stepState rKey rValue ( list, result ) =
            case list of
                [] ->
                    ( list, rightStep rKey rValue result )

                ( lKey, lValue ) :: rest ->
                    if lKey < rKey then
                        stepState rKey rValue ( rest, leftStep lKey lValue result )
                    else if lKey > rKey then
                        ( list, rightStep rKey rValue result )
                    else
                        ( rest, bothStep lKey lValue rValue result )

        ( leftovers, intermediateResult ) =
            foldl stepState ( toList leftDict, initialResult ) rightDict
    in
        List.foldl (\( k, v ) result -> leftStep k v result) intermediateResult leftovers



-- LISTS


{-| Get all of the keys in a dictionary, sorted from lowest to highest.
keys (fromList [(0,"Alice"),(1,"Bob")]) == [0,1]
-}
keys : Dict k v -> List k
keys dict =
    foldr (\key _ keyList -> key :: keyList) [] dict


{-| Get all of the values in a dictionary, in the order of their keys.
values (fromList [(0,"Alice"),(1,"Bob")]) == ["Alice", "Bob"]
-}
values : Dict k v -> List v
values dict =
    foldr (\_ value valueList -> value :: valueList) [] dict


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : Dict k v -> List ( k, v )
toList dict =
    foldr (\key value list -> ( key, value ) :: list) [] dict


{-| Convert an association list into a dictionary.
-}
fromList : List ( comparable, v ) -> Dict comparable v
fromList list =
    List.foldl (\( key, value ) dict -> insert key value dict) empty list



{-
   --  Validation code, useful for tests


   validateInvariants : Dict comparable v -> String
   validateInvariants dict =
       if not (isBST dict) then
           "Not in symmetric order"
       else if not (is23 dict) then
           "Not a 2-3 tree"
       else if not (isBalanced dict) then
           "Not balanced"
       else
           ""


   isBST : Dict comparable v -> Bool
   isBST dict =
       isBSTHelper True (keys dict)


   isBSTHelper : Bool -> List comparable -> Bool
   isBSTHelper acc keys =
       case keys of
           [] ->
               acc

           x :: [] ->
               acc

           x :: y :: xs ->
               isBSTHelper (acc && x < y) (y :: xs)


   is23 : Dict k v -> Bool
   is23 dict =
       is23Helper dict dict


   is23Helper : Dict k v -> Dict k v -> Bool
   is23Helper root node =
       case node of
           Leaf ->
               True

           Node clr _ _ left right ->
               if isRed right then
                   False
               else if node /= root && clr == Red && isRed left then
                   False
               else
                   is23Helper root left && is23Helper root right


   isRed : Dict k v -> Bool
   isRed dict =
       case dict of
           Node Red _ _ _ _ ->
               True

           _ ->
               False


   isBalanced : Dict k v -> Bool
   isBalanced dict =
       isBalancedHelper dict <| isBalancedBlacksHelper dict 0


   isBalancedBlacksHelper : Dict k v -> Int -> Int
   isBalancedBlacksHelper node blacks =
       case node of
           Leaf ->
               blacks

           Node color _ _ left _ ->
               if color == Red then
                   isBalancedBlacksHelper left blacks
               else
                   isBalancedBlacksHelper left (blacks + 1)


   isBalancedHelper : Dict k v -> Int -> Bool
   isBalancedHelper node blacks =
       case node of
           Leaf ->
               blacks == 0

           Node color _ _ left right ->
               let
                   nextBlacks =
                       if color == Red then
                           blacks
                       else
                           blacks - 1
               in
                   isBalancedHelper left nextBlacks && isBalancedHelper right nextBlacks
-}
