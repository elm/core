module Json.Encode exposing
  ( Value
  , encode
  , string, int, float, bool, null
  , list, array
  , object
  )

{-| Library for turning Elm values into Json values.

# Encoding
@docs encode, Value

# Primitives
@docs string, int, float, bool, null

# Arrays
@docs list, array

# Objects
@docs object
-}

import Array exposing (Array)
import Elm.Kernel.Json
import Elm.Kernel.List


{-| Represents a JavaScript value.
-}
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
    Elm.Kernel.Json.encode


{-|-}
string : String -> Value
string =
    Elm.Kernel.Json.identity


{-|-}
int : Int -> Value
int =
    Elm.Kernel.Json.identity


{-| Encode a Float. `Infinity` and `NaN` are encoded as `null`.
-}
float : Float -> Value
float =
    Elm.Kernel.Json.identity


{-|-}
bool : Bool -> Value
bool =
    Elm.Kernel.Json.identity


{-|-}
null : Value
null =
    Elm.Kernel.Json.encodeNull


{-|-}
object : List (String, Value) -> Value
object =
    Elm.Kernel.Json.encodeObject


{-|-}
array : Array Value -> Value
array arr =
    Array.toList >> Elm.Kernel.List.toArray


{-|-}
list : List Value -> Value
list =
    Elm.Kernel.List.toArray
