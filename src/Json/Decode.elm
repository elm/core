module Json.Decode exposing
  ( Decoder, string, bool, int, float
  , nullable, list, array, dict, keyValuePairs
  , field, at, index
  , maybe, oneOf
  , decodeString, decodeValue, Value
  , map, map2, map3, map4, map5, map6, map7, map8
  , lazy, value, null, succeed, fail, andThen
  )

{-| Turn JSON values into Elm values. Definitely check out this [intro to
JSON decoders][guide] to get a feel for how this library works!

[guide]: https://guide.elm-lang.org/interop/json.html

# Primitives
@docs Decoder, string, bool, int, float

# Data Structures
@docs nullable, list, array, dict, keyValuePairs

# Object Primitives
@docs field, at, index

# Inconsistent Structure
@docs maybe, oneOf

# Run Decoders
@docs decodeString, decodeValue, Value

# Mapping
@docs map, map2, map3, map4, map5, map6, map7, map8

# Fancy Decoding
@docs lazy, value, null, succeed, fail, andThen
-}


import Array exposing (Array)
import Dict exposing (Dict)
import Json.Encode as JsEncode
import List
import Maybe exposing (Maybe)
import Result exposing (Result(..))
import Native.Json



-- PRIMITIVES


{-| A value that knows how to decode JSON values.
-}
type Decoder a = Decoder


{-| Decode a JSON string into an Elm `String`.

    decodeString string "true"              == Err ...
    decodeString string "42"                == Err ...
    decodeString string "3.14"              == Err ...
    decodeString string "\"hello\""         == Ok "hello"
    decodeString string "{ \"hello\": 42 }" == Err ...
-}
string : Decoder String
string =
  Native.Json.decodePrimitive "string"


{-| Decode a JSON boolean into an Elm `Bool`.

    decodeString bool "true"              == Ok True
    decodeString bool "42"                == Err ...
    decodeString bool "3.14"              == Err ...
    decodeString bool "\"hello\""         == Err ...
    decodeString bool "{ \"hello\": 42 }" == Err ...
-}
bool : Decoder Bool
bool =
  Native.Json.decodePrimitive "bool"


{-| Decode a JSON number into an Elm `Int`.

    decodeString int "true"              == Err ...
    decodeString int "42"                == Ok 42
    decodeString int "3.14"              == Err ...
    decodeString int "\"hello\""         == Err ...
    decodeString int "{ \"hello\": 42 }" == Err ...
-}
int : Decoder Int
int =
  Native.Json.decodePrimitive "int"


{-| Decode a JSON number into an Elm `Float`.

    decodeString float "true"              == Err ..
    decodeString float "42"                == Ok 42
    decodeString float "3.14"              == Ok 3.14
    decodeString float "\"hello\""         == Err ...
    decodeString float "{ \"hello\": 42 }" == Err ...
-}
float : Decoder Float
float =
  Native.Json.decodePrimitive "float"



-- DATA STRUCTURES


{-| Decode a nullable JSON value into an Elm value.

    decodeString (nullable int) "13"    == Ok (Just 13)
    decodeString (nullable int) "42"    == Ok (Just 42)
    decodeString (nullable int) "null"  == Ok Nothing
    decodeString (nullable int) "true"  == Err ..
-}
nullable : Decoder a -> Decoder (Maybe a)
nullable decoder =
  oneOf
    [ null Nothing
    , map Just decoder
    ]


{-| Decode a JSON array into an Elm `List`.

    decodeString (list int) "[1,2,3]"       == Ok [1,2,3]
    decodeString (list bool) "[true,false]" == Ok [True,False]
-}
list : Decoder a -> Decoder (List a)
list decoder =
  Native.Json.decodeContainer "list" decoder


{-| Decode a JSON array into an Elm `Array`.

    decodeString (array int) "[1,2,3]"       == Ok (Array.fromList [1,2,3])
    decodeString (array bool) "[true,false]" == Ok (Array.fromList [True,False])
-}
array : Decoder a -> Decoder (Array a)
array decoder =
  Native.Json.decodeContainer "array" decoder


{-| Decode a JSON object into an Elm `Dict`.

    decodeString (dict int) "{ \"alice\": 42, \"bob\": 99 }"
      == Dict.fromList [("alice", 42), ("bob", 99)]
-}
dict : Decoder a -> Decoder (Dict String a)
dict decoder =
  map Dict.fromList (keyValuePairs decoder)


{-| Decode a JSON object into an Elm `List` of pairs.

    decodeString (keyValuePairs int) "{ \"alice\": 42, \"bob\": 99 }"
      == [("alice", 42), ("bob", 99)]
-}
keyValuePairs : Decoder a -> Decoder (List (String, a))
keyValuePairs =
  Native.Json.decodeKeyValuePairs



-- OBJECT PRIMITIVES


field : String -> Decoder a -> Decoder a
field =
    Native.Json.decodeField


at : List String -> Decoder a -> Decoder a
at fields decoder =
    List.foldr field decoder fields


index : Int -> Decoder a -> Decoder a
index =
    Native.Json.decodeIndex


-- WEIRD STRUCTURE


maybe : Decoder a -> Decoder (Maybe a)
maybe decoder =
  Native.Json.decodeContainer "maybe" decoder


oneOf : List (Decoder a) -> Decoder a
oneOf =
    Native.Json.oneOf



-- OBJECT HELPERS


map : (a -> value) -> Decoder a -> Decoder value
map =
    Native.Json.map1


map2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
map2 =
    Native.Json.map2


map3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
map3 =
    Native.Json.map3


map4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
map4 =
    Native.Json.map4


map5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
map5 =
    Native.Json.map5


map6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
map6 =
    Native.Json.map6


map7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
map7 =
    Native.Json.map7


map8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
map8 =
    Native.Json.map8



-- RUN DECODERS


decodeString : Decoder a -> String -> Result String a
decodeString =
  Native.Json.runOnString


decodeValue : Decoder a -> Value -> Result String a
decodeValue =
  Native.Json.run


type alias Value = JsEncode.Value



-- FANCY PRIMITIVES


succeed : a -> Decoder a
succeed =
  Native.Json.succeed


fail : String -> Decoder a
fail =
  Native.Json.fail


andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen =
  Native.Json.andThen


{-| Sometimes you have JSON with recursive structure, like nested comments.
You can use `lazy` to make sure your decoder unrolls lazily.

    type alias Comment =
      { message : String
      , responses : Responses
      }

    type Responses = Responses (List Comment)

    comment : Decoder Comment
    comment =
      object Comment
        |> required "message" string
        |> required "responses" (map Responses (list (lazy (\_ -> comment))))

If we had said `list comment` instead, we would start expanding the value
infinitely. What is a `comment`? It is a decoder for objects where the
`responses` field contains comments. What is a `comment` though? Etc.

By using `list (lazy (\_ -> comment))` we make sure the decoder only expands
to be as deep as the JSON we are given. You can read more about recursive data
structures [here][].

[here]: https://github.com/elm-lang/elm-compiler/blob/master/hints/recursive-alias.md
-}
lazy : (() -> Decoder a) -> Decoder a
lazy thunk =
  let
    lazilyDecode jsValue =
      case decodeValue (thunk ()) jsValue of
        Ok value ->
          succeed value

        Err msg ->
          fail msg
  in
    andThen lazilyDecode value


value : Decoder Value
value =
  Native.Json.decodePrimitive "value"


null : a -> Decoder a
null =
  Native.Json.decodeNull
