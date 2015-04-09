
module Json.Encode where

{-| Library for turning Elm values into Json values.

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
import Native.Json


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
    Native.Json.encode


string : String -> Value
string =
    Native.Json.identity

int : Int -> Value
int =
    Native.Json.identity


float : Float -> Value
float =
    Native.Json.identity


bool : Bool -> Value
bool =
    Native.Json.identity


null : Value
null =
    Native.Json.encodeNull


object : List (String, Value) -> Value
object =
    Native.Json.encodeObject


array : Array Value -> Value
array =
    Native.Json.encodeArray


list : List Value -> Value
list =
    Native.Json.encodeList
