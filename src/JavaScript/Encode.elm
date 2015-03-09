
module JavaScript.Encode where

{-| Library for turning Elm values into JavaScript values.

# Encoding
@docs encode

# Primitives
@docs string, int, float, bool, null

# Arrays
@docs list, array

# Objects
@docs object
-}

import Array exposing (Array)
import Native.JavaScript


type Value = Value


{-| Convert a `Value` into a prettified string. The first argument specifies
the amount of indentation in the resulting string.

    person =
        object
          [ ("name", string "Tom")
          , ("age", int 42)
          ]

    compact = encode 0 person
    -- {"name":"Tom","age":42}

    readable = encode 4 person
    -- {
    --     "name": "Tom",
    --     "age": 42
    -- }
-}
encode : Int -> Value -> String
encode =
    Native.JavaScript.encode


string : String -> Value
string =
    Native.JavaScript.identity

int : Int -> Value
int =
    Native.JavaScript.identity


float : Float -> Value
float =
    Native.JavaScript.identity


bool : Bool -> Value
bool =
    Native.JavaScript.identity


null : Value
null =
    Native.JavaScript.encodeNull


object : List (String, Value) -> Value
object =
    Native.JavaScript.encodeObject


array : Array Value -> Value
array =
    Native.JavaScript.encodeArray


list : List Value -> Value
list =
    Native.JavaScript.encodeList
