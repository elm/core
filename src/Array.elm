module Array
    exposing
        ( Array
        , empty
        , isEmpty
        , length
        , initialize
        , repeat
        , fromList
        , toList
        , toIndexedList
        , push
        , get
        , set
        , foldr
        , foldl
        , append
        , filter
        , map
        , indexedMap
        , slice
        )

{-| Fast immutable arrays. The elements in an array must have the
same type.

# Arrays
@docs Array

# Creating Arrays
@docs empty, repeat, initialize, fromList

# Basics
@docs isEmpty, length, push, append

# Get and Set
@docs get, set

# Taking Arrays Apart
@docs slice, toList, toIndexedList

# Mapping, Filtering, and Folding
@docs map, indexedMap, filter, foldl, foldr
-}

import JsArray
import Basics exposing (..)
import Bitwise
import Debug
import Maybe exposing (Maybe(Just, Nothing))
import List exposing ((::))
import Native.Array


{-| Representation of fast immutable arrays. You can create arrays of integers
(`Array Int`) or strings (`Array String`) or any other type of value you can
dream up.
-}
type alias Array a =
    { length : Int
    , startShift : Int
    , tree : Tree a
    , tail : Tree a
    }


type alias Tree a =
    JsArray.JsArray (Node a)


type Node a
    = Value a
    | SubTree (Tree a)


crashMsg : String
crashMsg =
    "This is a bug. Please report this."


{-| Return an empty array.

    length empty == 0
-}
empty : Array a
empty =
    Array 0 5 JsArray.empty JsArray.empty


{-| Determine if an array is empty.

    isEmpty empty == True
-}
isEmpty : Array a -> Bool
isEmpty arr =
    arr.length == 0


{-| Return the length of an array.

    length (fromList [1,2,3]) == 3
-}
length : Array a -> Int
length arr =
    arr.length


{-| Initialize an array. `initialize n f` creates an array of length `n` with
the element at index `i` initialized to the result of `(f i)`.

    initialize 4 identity    == fromList [0,1,2,3]
    initialize 4 (\n -> n*n) == fromList [0,1,4,9]
    initialize 4 (always 0)  == fromList [0,0,0,0]
-}
initialize : Int -> (Int -> a) -> Array a
initialize stop f =
    let
        initialize' idx acc =
            if stop <= idx then
                acc
            else
                initialize' (idx + 1) (push (f idx) acc)
    in
        initialize' 0 empty


{-| Creates an array with a given length, filled with a default element.

    repeat 5 0     == fromList [0,0,0,0,0]
    repeat 3 "cat" == fromList ["cat","cat","cat"]

Notice that `repeat 3 x` is the same as `initialize 3 (always x)`.
-}
repeat : Int -> a -> Array a
repeat n e =
    initialize n (always e)


{-| Create an array from a list.
-}
fromList : List a -> Array a
fromList ls =
    List.foldl push empty ls


{-| Create a list of elements from an array.

    toList (fromList [3,5,8]) == [3,5,8]
-}
toList : Array a -> List a
toList arr =
    foldr (\n acc -> n :: acc) [] arr


{-| Create an indexed list from an array. Each element of the array will be
paired with its index.

    toIndexedList (fromList ["cat","dog"]) == [(0,"cat"), (1,"dog")]
-}
toIndexedList : Array a -> List ( Int, a )
toIndexedList arr =
    let
        foldr' n ( idx, ls ) =
            ( idx - 1, ( idx, n ) :: ls )
    in
        snd <| foldr foldr' ( length arr - 1, [] ) arr


{-| Push an element to the end of an array.

    push 3 (fromList [1,2]) == fromList [1,2,3]
-}
push : a -> Array a -> Array a
push a arr =
    let
        newLen =
            arr.length + 1

        newShift =
            calcStartShift newLen

        newTail =
            JsArray.push (Value a) arr.tail

        tailLen =
            JsArray.length newTail

        newTree =
            if tailLen == 32 then
                tailPush arr.startShift arr.length newTail arr.tree
            else
                arr.tree
    in
        { length = newLen
        , startShift = newShift
        , tree =
            if newShift > arr.startShift then
                JsArray.singleton (SubTree newTree)
            else
                newTree
        , tail =
            if tailLen == 32 then
                JsArray.empty
            else
                newTail
        }


tailPush : Int -> Int -> Tree a -> Tree a -> Tree a
tailPush shift idx tail tree =
    let
        pos =
            indexPositionWithShift shift idx
    in
        case JsArray.get pos tree of
            Just x ->
                case x of
                    SubTree subTree ->
                        let
                            newSub =
                                tailPush (shift - 5) idx tail subTree
                        in
                            JsArray.set pos (SubTree newSub) tree

                    Value _ ->
                        JsArray.singleton (SubTree tree)
                            |> tailPush shift idx tail

            Nothing ->
                JsArray.push (SubTree tail) tree


{-| Calculate the shift required for the root tree.
-}
calcStartShift : Int -> Int
calcStartShift len =
    if len < 1024 then
        5
    else
        (len |> toFloat |> logBase 32 |> floor) * 5


{-| At what index does the tail begin.
-}
tailPrefix : Int -> Int
tailPrefix len =
    if len < 32 then
        0
    else
        ((len - 1) `Bitwise.shiftRightLogical` 5) `Bitwise.shiftLeft` 5


{-| Given an index and a shift, figure out what element in a tree we should
look at next.
-}
indexPositionWithShift : Int -> Int -> Int
indexPositionWithShift shift index =
    Bitwise.and 0x1F <| Bitwise.shiftRightLogical index shift


{-| Return Just the element at the index or Nothing if the index is out of range.

    get  0 (fromList [0,1,2]) == Just 0
    get  2 (fromList [0,1,2]) == Just 2
    get  5 (fromList [0,1,2]) == Nothing
    get -1 (fromList [0,1,2]) == Nothing
-}
get : Int -> Array a -> Maybe a
get idx arr =
    if idx >= (tailPrefix arr.length) then
        case JsArray.get (idx `Bitwise.and` 0x1F) arr.tail of
            Just x ->
                case x of
                    Value v ->
                        Just v

                    SubTree _ ->
                        Debug.crash crashMsg

            Nothing ->
                Nothing
    else
        getRecursive arr.startShift idx arr.tree


getRecursive : Int -> Int -> Tree a -> Maybe a
getRecursive shift idx tree =
    let
        pos =
            indexPositionWithShift shift idx
    in
        case JsArray.get pos tree of
            Just x ->
                case x of
                    Value v ->
                        Just v

                    SubTree subTree ->
                        getRecursive (shift - 5) idx subTree

            Nothing ->
                Nothing


{-| Set the element at a particular index. Returns an updated array.
If the index is out of range, the array is unaltered.

    set 1 7 (fromList [1,2,3]) == fromList [1,7,3]
-}
set : Int -> a -> Array a -> Array a
set idx val arr =
    if idx < 0 || idx >= arr.length then
        arr
    else if idx >= (tailPrefix arr.length) then
        { length = arr.length
        , startShift = arr.startShift
        , tree = arr.tree
        , tail = JsArray.set (idx `Bitwise.and` 0x1F) (Value val) arr.tail
        }
    else
        { length = arr.length
        , startShift = arr.startShift
        , tree = setRecursive arr.startShift idx val arr.tree
        , tail = arr.tail
        }


setRecursive : Int -> Int -> a -> Tree a -> Tree a
setRecursive shift idx val tree =
    let
        pos =
            indexPositionWithShift shift idx
    in
        case JsArray.get pos tree of
            Just x ->
                case x of
                    Value _ ->
                        JsArray.set pos (Value val) tree

                    SubTree subTree ->
                        setRecursive (shift - 5) idx val subTree

            Nothing ->
                Debug.crash crashMsg


{-| Reduce an array from the right. Read `foldr` as fold from the right.

    foldr (+) 0 (repeat 3 5) == 15
-}
foldr : (a -> b -> b) -> b -> Array a -> b
foldr f init arr =
    let
        foldr' i acc =
            case i of
                Value v ->
                    f v acc

                SubTree subTree ->
                    JsArray.foldr foldr' acc subTree

        tail =
            JsArray.foldr foldr' init arr.tail
    in
        JsArray.foldr foldr' tail arr.tree


{-| Reduce an array from the left. Read `foldl` as fold from the left.

    foldl (::) [] (fromList [1,2,3]) == [3,2,1]
-}
foldl : (a -> b -> b) -> b -> Array a -> b
foldl f init arr =
    let
        foldl' i acc =
            case i of
                Value v ->
                    f v acc

                SubTree subTree ->
                    JsArray.foldl foldl' acc subTree

        tree =
            JsArray.foldl foldl' init arr.tree
    in
        JsArray.foldl foldl' tree arr.tail


{-| Append two arrays to a new one.

    append (repeat 2 42) (repeat 3 81) == fromList [42,42,81,81,81]
-}
append : Array a -> Array a -> Array a
append a b =
    foldl push a b


{-| Keep only elements that satisfy the predicate:

    filter isEven (fromList [1..6]) == (fromList [2,4,6])
-}
filter : (a -> Bool) -> Array a -> Array a
filter f arr =
    let
        update n acc =
            if f n then
                push n acc
            else
                acc
    in
        foldl update empty arr


{-| Apply a function on every element in an array.

    map sqrt (fromList [1,4,9]) == fromList [1,2,3]
-}
map : (a -> b) -> Array a -> Array b
map f arr =
    foldl (\n acc -> push (f n) acc) empty arr


{-| Apply a function on every element with its index as first argument.

    indexedMap (*) (fromList [5,5,5]) == fromList [0,5,10]
-}
indexedMap : (Int -> a -> b) -> Array a -> Array b
indexedMap f arr =
    let
        foldl' i ( idx, acc ) =
            ( idx + 1, push (f idx i) acc )
    in
        snd <| foldl foldl' ( 0, empty ) arr


{-| Get a sub-section of an array: `(slice start end array)`. The `start` is a
zero-based index where we will start our slice. The `end` is a zero-based index
that indicates the end of the slice. The slice extracts up to but not including
`end`.

    slice  0  3 (fromList [0,1,2,3,4]) == fromList [0,1,2]
    slice  1  4 (fromList [0,1,2,3,4]) == fromList [1,2,3]

Both the `start` and `end` indexes can be negative, indicating an offset from
the end of the array.

    slice  1 -1 (fromList [0,1,2,3,4]) == fromList [1,2,3]
    slice -2  5 (fromList [0,1,2,3,4]) == fromList [3,4]

This makes it pretty easy to `pop` the last element off of an array: `slice 0 -1 array`
-}
slice : Int -> Int -> Array a -> Array a
slice from to arr =
    let
        correctFrom =
            translateIndex from arr

        correctTo =
            translateIndex to arr
    in
        if isEmpty arr || correctFrom > correctTo then
            empty
        else
            let
                foldl' i ( idx, acc ) =
                    if idx >= correctFrom && idx < correctTo then
                        ( idx + 1, push i acc )
                    else
                        ( idx + 1, acc )
            in
                snd <| foldl foldl' ( 0, empty ) arr


translateIndex : Int -> Array a -> Int
translateIndex idx arr =
    let
        posIndex =
            if idx < 0 then
                arr.length + idx
            else
                idx
    in
        if posIndex < 0 then
            0
        else if posIndex > arr.length then
            arr.length
        else
            posIndex
