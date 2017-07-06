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

    import Json.Encode as Encode

    tom : Encode.Value
    tom =
        Encode.object
            [ ( "name", Encode.string "Tom" )
            , ( "age", Encode.int 42 )
            ]

    compact = Encode.encode 0 tom
    -- {"name":"Tom","age":42}

    readable = Encode.encode 4 tom
    -- {
    --     "name": "Tom",
    --     "age": 42
    -- }
-}
encode : Int -> Value -> String
encode =
    Elm.Kernel.Json.encode


{-| Turn a `String` into a JSON string.

    import Json.Encode exposing (encode, string)

    -- encode 0 (string "")      == "\"\""
    -- encode 0 (string "abc")   == "\"abc\""
    -- encode 0 (string "hello") == "\"hello\""
-}
string : String -> Value
string =
    Elm.Kernel.Json.identity


{-| Turn an `Int` into a JSON number.

    import Json.Encode exposing (encode, int)

    -- encode 0 (int 42) == "42"
    -- encode 0 (int -7) == "-7"
    -- encode 0 (int 0)  == "0"
-}
int : Int -> Value
int =
    Elm.Kernel.Json.identity


{-| Turn a `Float` into a JSON number.

    import Json.Encode exposing (encode, float)

    -- encode 0 (float 3.14)     == "3.14"
    -- encode 0 (float 1.618)    == "1.618"
    -- encode 0 (float -42)      == "-42"
    -- encode 0 (float NaN)      == "null"
    -- encode 0 (float Infinity) == "null"

**Note:** Floating point numbers are defined in the [IEEE 754 standard][ieee]
which is hardcoded into almost all CPUs. This standard allows `Infinity` and
`NaN`. [The JSON spec][json] does not include these values, so we encode them
both as `null`.

[ieee]: https://en.wikipedia.org/wiki/IEEE_754
[json]: http://www.json.org/
-}
float : Float -> Value
float =
    Elm.Kernel.Json.identity


{-| Turn a `Bool` into a JSON boolean.

    import Json.Encode exposing (encode, bool)

    -- encode 0 (bool True)  == "true"
    -- encode 0 (bool False) == "false"
-}
bool : Bool -> Value
bool =
    Elm.Kernel.Json.identity


{-| Create a JSON `null` value.

    import Json.Encode exposing (encode, null)

    -- encode 0 null == "null"
-}
null : Value
null =
    Elm.Kernel.Json.encodeNull


{-| Create a JSON object.

    import Json.Encode as Encode

    tom : Encode.Value
    tom =
        Encode.object
            [ ( "name", Encode.string "Tom" )
            , ( "age", Encode.int 42 )
            ]

    -- Encode.encode 0 tom == """{"name":"Tom","age":42}"""
-}
object : List (String, Value) -> Value
object =
    Elm.Kernel.Json.encodeObject


{-|-}
array : Array Value -> Value
array array =
    Elm.Kernel.List.toArray (Array.toList array)


{-|-}
list : List Value -> Value
list =
    Elm.Kernel.List.toArray
