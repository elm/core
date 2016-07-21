module JsArray
    exposing
        ( JsArray
        , empty
        , singleton
        , length
        , get
        , set
        , push
        , foldl
        , foldr
        )

{-| A module that exposes native Javascript arrays to Elm.
The arrays are will be copied before modification, so performance will suffer
when the size of the array becomes large.

As this module primarily exist to serve as the foundation for Elm's Array
implementation, the number of functions in this module is rather sparse.

# Arrays
@docs Array

# Creating Arrays
@docs empty, singleton

# Basics
@docs length, push

# Get and Set
@docs get, set

# Mapping, Filtering, and Folding
@docs foldl, foldr
-}

import Native.JsArray


{-| A native Javascript Array. Can contain any kind of element.
-}
type JsArray a
    = JsArray a


{-| An empty array.
-}
empty : JsArray a
empty =
    Native.JsArray.empty


{-| Creates an array containing a single element.
-}
singleton : a -> JsArray a
singleton =
    Native.JsArray.singleton


{-| Returns the length of the array.
-}
length : JsArray a -> Int
length =
    Native.JsArray.length


{-| Get the element at the given index. Returns nothing if requesting
element that is out of bounds.
-}
get : Int -> JsArray a -> Maybe a
get =
    Native.JsArray.get


{-| Sets an element at a given index. Returns an unmodified array if
index is out of bounds.
-}
set : Int -> a -> JsArray a -> JsArray a
set =
    Native.JsArray.set


{-| Pushes an element to the end of the array, increasing its size.
-}
push : a -> JsArray a -> JsArray a
push =
    Native.JsArray.push


{-| Runs the given function once for every element in the array, in a
left-to-right order.
-}
foldl : (a -> b -> b) -> b -> JsArray a -> b
foldl =
    Native.JsArray.foldl


{-| Runs the given function once for every element in the array, in a
right-to-left order.
-}
foldr : (a -> b -> b) -> b -> JsArray a -> b
foldr =
    Native.JsArray.foldr
