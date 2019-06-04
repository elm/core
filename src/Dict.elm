module Dict exposing
    ( Dict
    , empty, singleton, insert, update, remove
    , isEmpty, member, get, size
    , keys, values, toList, fromList
    , map, foldl, foldr, filter, partition
    , union, intersect, diff, merge
    )

{-| A dictionary mapping unique keys to values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.

Insert, remove, and query operations all take _O(log n)_ time.


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
import List exposing (..)
import Maybe exposing (..)



-- DICTIONARIES
-- The color of a node. Leaves are considered Black.


type NColor
    = Red
    | Black


{-| A dictionary of keys and values. So a `Dict String User` is a dictionary
that lets you look up a `String` (such as user names) and find the associated
`User`.

    import Dict exposing (Dict)

    users : Dict String User
    users =
        Dict.fromList
            [ ( "Alice", User "Alice" 28 1.65 )
            , ( "Bob", User "Bob" 19 1.82 )
            , ( "Chuck", User "Chuck" 33 1.75 )
            ]

    type alias User =
        { name : String
        , age : Int
        , height : Float
        }

-}
type Dict k v
    = RBNode_elm_builtin NColor k v (Dict k v) (Dict k v)
    | RBEmpty_elm_builtin
      -- Temporary state used when removing elements
    | RBBlackMissing_elm_builtin (Dict k v)


{-| Create an empty dictionary.
-}
empty : Dict k v
empty =
    RBEmpty_elm_builtin


{-| Create a dictionary with one key-value pair.
-}
singleton : comparable -> v -> Dict comparable v
singleton key value =
    -- Root node is always Black
    RBNode_elm_builtin Black key value RBEmpty_elm_builtin RBEmpty_elm_builtin


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
        RBNode_elm_builtin _ key value left right ->
            case compare targetKey key of
                LT ->
                    get targetKey left

                EQ ->
                    Just value

                GT ->
                    get targetKey right

        _ ->
            Nothing


{-| Determine if a key is in a dictionary.
-}
member : comparable -> Dict comparable v -> Bool
member key dict =
    case get key dict of
        Just _ ->
            True

        Nothing ->
            False


{-| Determine the number of key-value pairs in the dictionary.
-}
size : Dict k v -> Int
size dict =
    sizeHelp 0 dict


sizeHelp : Int -> Dict k v -> Int
sizeHelp n dict =
    case dict of
        RBNode_elm_builtin _ _ _ left right ->
            sizeHelp (sizeHelp (n + 1) right) left

        _ ->
            n


{-| Determine if a dictionary is empty.

    isEmpty_elm_builtin empty == True

-}
isEmpty : Dict k v -> Bool
isEmpty dict =
    case dict of
        RBNode_elm_builtin _ _ _ _ _ ->
            False

        _ ->
            True


{-| Insert a key-value pair into a dictionary. Replaces value when there is
a collision.
-}
insert : comparable -> v -> Dict comparable v -> Dict comparable v
insert key value dict =
    -- Root node is always Black
    case insertHelp key value dict of
        RBNode_elm_builtin Red k v l r ->
            RBNode_elm_builtin Black k v l r

        x ->
            x


insertHelp : comparable -> v -> Dict comparable v -> Dict comparable v
insertHelp key value dict =
    case dict of
        RBNode_elm_builtin nColor nKey nValue nLeft nRight ->
            case compare key nKey of
                LT ->
                    case insertHelp key value nLeft of
                        RBNode_elm_builtin Red lK lV (RBNode_elm_builtin Red llK llV llLeft llRight) lRight ->
                            RBNode_elm_builtin Red lK lV (RBNode_elm_builtin Black llK llV llLeft llRight) (RBNode_elm_builtin Black nKey nValue lRight nRight)

                        newLeft ->
                            RBNode_elm_builtin nColor nKey nValue newLeft nRight

                EQ ->
                    RBNode_elm_builtin nColor nKey value nLeft nRight

                GT ->
                    case insertHelp key value nRight of
                        RBNode_elm_builtin Red rK rV rLeft rRight ->
                            case nLeft of
                                RBNode_elm_builtin Red lK lV lLeft lRight ->
                                    RBNode_elm_builtin
                                        Red
                                        nKey
                                        nValue
                                        (RBNode_elm_builtin Black lK lV lLeft lRight)
                                        (RBNode_elm_builtin Black rK rV rLeft rRight)

                                _ ->
                                    RBNode_elm_builtin nColor rK rV (RBNode_elm_builtin Red nKey nValue nLeft rLeft) rRight

                        newRight ->
                            RBNode_elm_builtin nColor nKey nValue nLeft newRight

        _ ->
            -- New nodes are always red. If it violates the rules, it will be fixed
            -- when balancing.
            RBNode_elm_builtin Red key value RBEmpty_elm_builtin RBEmpty_elm_builtin


{-| Remove a key-value pair from a dictionary. If the key is not found,
no changes are made.
-}
remove : comparable -> Dict comparable v -> Dict comparable v
remove key dict =
    -- Root node is always Black
    case removeHelp key dict of
        RBNode_elm_builtin Red k v l r ->
            RBNode_elm_builtin Black k v l r

        RBBlackMissing_elm_builtin node ->
            case node of
                RBNode_elm_builtin Red k v l r ->
                    RBNode_elm_builtin Black k v l r

                validNode ->
                    validNode

        validNode ->
            validNode


removeHelp : comparable -> Dict comparable v -> Dict comparable v
removeHelp key dict =
    case dict of
        RBNode_elm_builtin clr k v left right ->
            case compare key k of
                LT ->
                    balanceRemoveLeft clr k v (removeHelp key left) right

                EQ ->
                    case getMin right of
                        RBNode_elm_builtin _ minKey minValue _ _ ->
                            balanceRemoveRight clr minKey minValue left (removeMin right)

                        _ ->
                            case left of
                                RBNode_elm_builtin Red lK lV lLeft lRight ->
                                    RBNode_elm_builtin Black lK lV lLeft lRight

                                RBNode_elm_builtin Black _ _ _ _ ->
                                    left

                                _ ->
                                    case clr of
                                        Black ->
                                            RBBlackMissing_elm_builtin RBEmpty_elm_builtin

                                        Red ->
                                            RBEmpty_elm_builtin

                GT ->
                    balanceRemoveRight clr k v left (removeHelp key right)

        _ ->
            RBEmpty_elm_builtin


getMin : Dict comparable v -> Dict comparable v
getMin dict =
    case dict of
        RBNode_elm_builtin _ minKey minValue ((RBNode_elm_builtin _ _ _ _ _) as left) _ ->
            getMin left

        _ ->
            dict


removeMin : Dict comparable v -> Dict comparable v
removeMin dict =
    case dict of
        RBNode_elm_builtin Red key value RBEmpty_elm_builtin _ ->
            RBEmpty_elm_builtin

        RBNode_elm_builtin Black key value RBEmpty_elm_builtin _ ->
            RBBlackMissing_elm_builtin RBEmpty_elm_builtin

        RBNode_elm_builtin clr key value left right ->
            balanceRemoveLeft clr key value (removeMin left) right

        _ ->
            RBEmpty_elm_builtin


balanceRemoveLeft : NColor -> comparable -> v -> Dict comparable v -> Dict comparable v -> Dict comparable v
balanceRemoveLeft clr key value left right =
    case left of
        RBBlackMissing_elm_builtin leftNode ->
            case right of
                RBNode_elm_builtin Black rK rV (RBNode_elm_builtin Red rlK rlV rlLeft rlRight) rRight ->
                    RBNode_elm_builtin clr rlK rlV (RBNode_elm_builtin Black key value leftNode rlLeft) (RBNode_elm_builtin Black rK rV rlRight rRight)

                RBNode_elm_builtin Black rK rV rLeft rRight ->
                    case clr of
                        Red ->
                            RBNode_elm_builtin Black rK rV (RBNode_elm_builtin Red key value leftNode rLeft) rRight

                        Black ->
                            RBBlackMissing_elm_builtin (RBNode_elm_builtin clr rK rV (RBNode_elm_builtin Red key value leftNode rLeft) rRight)

                _ ->
                    RBNode_elm_builtin clr key value left right

        _ ->
            RBNode_elm_builtin clr key value left right


balanceRemoveRight : NColor -> comparable -> v -> Dict comparable v -> Dict comparable v -> Dict comparable v
balanceRemoveRight clr key value left right =
    case right of
        RBBlackMissing_elm_builtin rightNode ->
            case left of
                RBNode_elm_builtin Black lK lV (RBNode_elm_builtin Red llK llV llLeft llRight) lRight ->
                    RBNode_elm_builtin clr lK lV (RBNode_elm_builtin Black llK llV llLeft llRight) (RBNode_elm_builtin Black key value lRight rightNode)

                RBNode_elm_builtin Black lK lV lLeft lRight ->
                    case clr of
                        Red ->
                            RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lK lV lLeft lRight) rightNode

                        Black ->
                            RBBlackMissing_elm_builtin (RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lK lV lLeft lRight) rightNode)

                RBNode_elm_builtin Red lK lV lLeft (RBNode_elm_builtin Black lrK lrV lrLeft lrRight) ->
                    RBNode_elm_builtin Black lK lV lLeft (RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lrK lrV lrLeft lrRight) rightNode)

                _ ->
                    RBNode_elm_builtin clr key value left right

        _ ->
            RBNode_elm_builtin clr key value left right


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : comparable -> (Maybe v -> Maybe v) -> Dict comparable v -> Dict comparable v
update targetKey alter dict =
    -- Root node is always Black
    case updateHelp targetKey alter dict of
        RBNode_elm_builtin Red k v l r ->
            RBNode_elm_builtin Black k v l r

        RBBlackMissing_elm_builtin node ->
            case node of
                RBNode_elm_builtin Red k v l r ->
                    RBNode_elm_builtin Black k v l r

                validNode ->
                    validNode

        validNode ->
            validNode


updateHelp : comparable -> (Maybe v -> Maybe v) -> Dict comparable v -> Dict comparable v
updateHelp key alter dict =
    case dict of
        RBNode_elm_builtin clr k v left right ->
            case compare key k of
                LT ->
                    balanceUpdateLeft clr k v (updateHelp key alter left) right

                EQ ->
                    case alter (Just v) of
                        Just newValue ->
                            RBNode_elm_builtin clr k newValue left right

                        Nothing ->
                            case getMin right of
                                RBNode_elm_builtin _ minKey minValue _ _ ->
                                    balanceUpdateRight clr minKey minValue left (removeMin right)

                                _ ->
                                    case left of
                                        RBNode_elm_builtin Red lK lV lLeft lRight ->
                                            RBNode_elm_builtin Black lK lV lLeft lRight

                                        RBNode_elm_builtin Black _ _ _ _ ->
                                            left

                                        _ ->
                                            case clr of
                                                Black ->
                                                    RBBlackMissing_elm_builtin RBEmpty_elm_builtin

                                                Red ->
                                                    RBEmpty_elm_builtin

                GT ->
                    balanceUpdateRight clr k v left (updateHelp key alter right)

        _ ->
            case alter Nothing of
                Just value ->
                    RBNode_elm_builtin Red key value RBEmpty_elm_builtin RBEmpty_elm_builtin

                Nothing ->
                    dict


balanceUpdateLeft : NColor -> comparable -> v -> Dict comparable v -> Dict comparable v -> Dict comparable v
balanceUpdateLeft clr key value left right =
    case left of
        RBBlackMissing_elm_builtin leftNode ->
            case right of
                RBNode_elm_builtin Black rK rV (RBNode_elm_builtin Red rlK rlV rlLeft rlRight) rRight ->
                    RBNode_elm_builtin clr rlK rlV (RBNode_elm_builtin Black key value leftNode rlLeft) (RBNode_elm_builtin Black rK rV rlRight rRight)

                RBNode_elm_builtin Black rK rV rLeft rRight ->
                    case clr of
                        Red ->
                            RBNode_elm_builtin Black rK rV (RBNode_elm_builtin Red key value leftNode rLeft) rRight

                        Black ->
                            RBBlackMissing_elm_builtin (RBNode_elm_builtin clr rK rV (RBNode_elm_builtin Red key value leftNode rLeft) rRight)

                _ ->
                    RBNode_elm_builtin clr key value left right

        RBNode_elm_builtin Red lK lV (RBNode_elm_builtin Red llK llV llLeft llRight) lRight ->
            RBNode_elm_builtin Red lK lV (RBNode_elm_builtin Black llK llV llLeft llRight) (RBNode_elm_builtin Black key value lRight right)

        _ ->
            RBNode_elm_builtin clr key value left right


balanceUpdateRight : NColor -> comparable -> v -> Dict comparable v -> Dict comparable v -> Dict comparable v
balanceUpdateRight clr key value left right =
    case right of
        RBBlackMissing_elm_builtin rightNode ->
            case left of
                RBNode_elm_builtin Black lK lV (RBNode_elm_builtin Red llK llV llLeft llRight) lRight ->
                    RBNode_elm_builtin clr lK lV (RBNode_elm_builtin Black llK llV llLeft llRight) (RBNode_elm_builtin Black key value lRight rightNode)

                RBNode_elm_builtin Black lK lV lLeft lRight ->
                    case clr of
                        Red ->
                            RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lK lV lLeft lRight) rightNode

                        Black ->
                            RBBlackMissing_elm_builtin (RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lK lV lLeft lRight) rightNode)

                RBNode_elm_builtin Red lK lV lLeft (RBNode_elm_builtin Black lrK lrV lrLeft lrRight) ->
                    RBNode_elm_builtin Black lK lV lLeft (RBNode_elm_builtin Black key value (RBNode_elm_builtin Red lrK lrV lrLeft lrRight) rightNode)

                _ ->
                    RBNode_elm_builtin clr key value left right

        RBNode_elm_builtin Red rK rV rLeft rRight ->
            case left of
                RBNode_elm_builtin Red lK lV lLeft lRight ->
                    RBNode_elm_builtin
                        Red
                        key
                        value
                        (RBNode_elm_builtin Black lK lV lLeft lRight)
                        (RBNode_elm_builtin Black rK rV rLeft rRight)

                _ ->
                    RBNode_elm_builtin clr rK rV (RBNode_elm_builtin Red key value left rLeft) rRight

        _ ->
            RBNode_elm_builtin clr key value left right



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
diff : Dict comparable a -> Dict comparable b -> Dict comparable a
diff t1 t2 =
    foldl (\k v t -> remove k t) t1 t2


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



-- TRANSFORM


{-| Apply a function to all values in a dictionary.
-}
map : (k -> a -> b) -> Dict k a -> Dict k b
map func dict =
    case dict of
        RBNode_elm_builtin color key value left right ->
            RBNode_elm_builtin color key (func key value) (map func left) (map func right)

        _ ->
            RBEmpty_elm_builtin


{-| Fold over the key-value pairs in a dictionary from lowest key to highest key.

    import Dict exposing (Dict)

    getAges : Dict String User -> List String
    getAges users =
        Dict.foldl addAge [] users

    addAge : String -> User -> List String -> List String
    addAge _ user ages =
        user.age :: ages

    -- getAges users == [33,19,28]

-}
foldl : (k -> v -> b -> b) -> b -> Dict k v -> b
foldl func acc dict =
    case dict of
        RBNode_elm_builtin _ key value left right ->
            foldl func (func key value (foldl func acc left)) right

        _ ->
            acc


{-| Fold over the key-value pairs in a dictionary from highest key to lowest key.

    import Dict exposing (Dict)

    getAges : Dict String User -> List String
    getAges users =
        Dict.foldr addAge [] users

    addAge : String -> User -> List String -> List String
    addAge _ user ages =
        user.age :: ages

    -- getAges users == [28,19,33]

-}
foldr : (k -> v -> b -> b) -> b -> Dict k v -> b
foldr func acc t =
    case t of
        RBNode_elm_builtin _ key value left right ->
            foldr func (func key value (foldr func acc right)) left

        _ ->
            acc


{-| Keep only the key-value pairs that pass the given test.
-}
filter : (comparable -> v -> Bool) -> Dict comparable v -> Dict comparable v
filter isGood dict =
    foldl
        (\k v d ->
            if isGood k v then
                insert k v d

            else
                d
        )
        empty
        dict


{-| Partition a dictionary according to some test. The first dictionary
contains all key-value pairs which passed the test, and the second contains
the pairs that did not.
-}
partition : (comparable -> v -> Bool) -> Dict comparable v -> ( Dict comparable v, Dict comparable v )
partition isGood dict =
    let
        add key value ( t1, t2 ) =
            if isGood key value then
                ( insert key value t1, t2 )

            else
                ( t1, insert key value t2 )
    in
    foldl add ( empty, empty ) dict



-- LISTS


{-| Get all of the keys in a dictionary, sorted from lowest to highest.

    keys (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ 0, 1 ]

-}
keys : Dict k v -> List k
keys dict =
    foldr (\key value keyList -> key :: keyList) [] dict


{-| Get all of the values in a dictionary, in the order of their keys.

    values (fromList [ ( 0, "Alice" ), ( 1, "Bob" ) ]) == [ "Alice", "Bob" ]

-}
values : Dict k v -> List v
values dict =
    foldr (\key value valueList -> value :: valueList) [] dict


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : Dict k v -> List ( k, v )
toList dict =
    foldr (\key value list -> ( key, value ) :: list) [] dict


{-| Convert an association list into a dictionary.
-}
fromList : List ( comparable, v ) -> Dict comparable v
fromList assocs =
    List.foldl (\( key, value ) dict -> insert key value dict) empty assocs
