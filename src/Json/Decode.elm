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

**Note:** If you run out of map functions, take a look at [elm-decode-pipeline][pipe]
which makes it easier to handle large objects, but produces lower quality type
errors.

[pipe]: http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest

@docs map, map2, map3, map4, map5, map6, map7, map8

# Fancy Decoding
@docs lazy, value, null, succeed, fail, andThen
-}


import Array exposing (Array)
import Dict exposing (Dict)
import Json.Encode as JsEncode
import List
import Maybe exposing (Maybe(..))
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


{-| Decode a JSON object, requiring a particular field.

    decodeString (field "x" int) "{ \"x\": 3 }"            == Ok 3
    decodeString (field "x" int) "{ \"x\": 3, \"y\": 4 }"  == Ok 3
    decodeString (field "x" int) "{ \"x\": true }"         == Err ...
    decodeString (field "x" int) "{ \"y\": 4 }"            == Err ...

    decodeString (field "name" string) "{ \"name\": \"tom\" }" == Ok "tom"

The object *can* have other fields. Lots of them! The only thing this decoder
cares about is if `x` is present and that the value there is an `Int`.

Check out [`map2`](#map2) to see how to decode multiple fields!
-}
field : String -> Decoder a -> Decoder a
field =
    Native.Json.decodeField


{-| Decode a nested JSON object, requiring certain fields.

    json = """{ "person": { "name": "tom", "age": 42 } }"""

    decodeString (at ["person", "name"] string) json  == Ok "tom"
    decodeString (at ["person", "age" ] int   ) json  == Ok "42

This is really just a shorthand for saying things like:

    field "person" (field "name" string) == at ["person","name"] string
-}
at : List String -> Decoder a -> Decoder a
at fields decoder =
    List.foldr field decoder fields


{-| Decode a JSON array, requiring a particular index.

    json = """[ "alice", "bob", "chuck" ]"""

    decodeString (index 0 string) json  == Ok "alice"
    decodeString (index 1 string) json  == Ok "bob"
    decodeString (index 2 string) json  == Ok "chuck"
    decodeString (index 3 string) json  == Err ...
-}
index : Int -> Decoder a -> Decoder a
index =
    Native.Json.decodeIndex



-- WEIRD STRUCTURE


{-| Helpful for dealing with optional fields. Here are a few slightly different
examples:

    json = """{ "name": "tom", "age": 42 }"""

    decodeString (maybe (field "age"    int  )) json == Ok (Just 42)
    decodeString (maybe (field "name"   int  )) json == Ok Nothing
    decodeString (maybe (field "height" float)) json == Ok Nothing

    decodeString (field "age"    (maybe int  )) json == Ok (Just 42)
    decodeString (field "name"   (maybe int  )) json == Ok Nothing
    decodeString (field "height" (maybe float)) json == Err ...

Notice the last example! It is saying we *must* have a field named `height` and
the content *may* be a float. There is no `height` field, so the decoder fails.

Point is, `maybe` will make exactly what it contains conditional. For optional
fields, this means you probably want it *outside* a use of `field` or `at`.
-}
maybe : Decoder a -> Decoder (Maybe a)
maybe decoder =
  Native.Json.decodeContainer "maybe" decoder


{-| Try a bunch of different decoders. This can be useful if the JSON may come
in a couple different formats. For example, say you want to read an array of
numbers, but some of them are `null`.

    import String

    badInt : Decoder Int
    badInt =
      oneOf [ int, null 0 ]

    -- decodeString (list badInt) "[1,2,null,4]" == Ok [1,2,0,4]

Why would someone generate JSON like this? Questions like this are not good
for your health. The point is that you can use `oneOf` to handle situations
like this!

You could also use `oneOf` to help version your data. Try the latest format,
then a few older ones that you still support. You could use `andThen` to be
even more particular if you wanted.
-}
oneOf : List (Decoder a) -> Decoder a
oneOf =
    Native.Json.oneOf



-- MAPPING


{-| Transform a decoder. Maybe you just want to know the length of a string:

    import String

    stringLength : Decoder Int
    stringLength =
      map String.length string

It is often helpful to use `map` with `oneOf`, like when defining `nullable`:

    nullable : Decoder a -> Decoder (Maybe a)
    nullable decoder =
      oneOf
        [ null Nothing
        , map Just decoder
        ]
-}
map : (a -> value) -> Decoder a -> Decoder value
map =
    Native.Json.map1


{-| Try two decoders and then combine the result. We can use this to decode
objects with many fields:

    type alias Point = { x : Float, y : Float }

    point : Decoder Point
    point =
      map2 Point
        (field "x" float)
        (field "y" float)

    -- decodeString point """{ "x": 3, "y": 4 }""" == Ok { x = 3, y = 4 }

It tries each individual decoder and puts the result together with the `Point`
constructor.
-}
map2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
map2 =
    Native.Json.map2


{-| Try three decoders and then combine the result. We can use this to decode
objects with many fields:

    type alias Person = { name : String, age : Int, height : Float }

    person : Decoder Person
    person =
      map3 Person
        (at ["name"] string)
        (at ["info","age"] int)
        (at ["info","height"] float)

    -- json = """{ "name": "tom", "info": { "age": 42, "height": 1.8 } }"""
    -- decodeString point json == Ok { name = "tom", age = 42, height = 1.8 }

Like `map2` it tries each decoder in order and then give the results to the
`Person` constructor. That can be any function though!
-}
map3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
map3 =
    Native.Json.map3


{-|-}
map4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
map4 =
    Native.Json.map4


{-|-}
map5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
map5 =
    Native.Json.map5


{-|-}
map6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
map6 =
    Native.Json.map6


{-|-}
map7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
map7 =
    Native.Json.map7


{-|-}
map8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
map8 =
    Native.Json.map8



-- RUN DECODERS


{-| Parse the given string into a JSON value and then run the `Decoder` on it.
This will fail if the string is not well-formed JSON or if the `Decoder`
fails for some reason.

    decodeString int "4"     == Ok 4
    decodeString int "1 + 2" == Err ...
-}
decodeString : Decoder a -> String -> Result String a
decodeString =
  Native.Json.runOnString


{-| Run a `Decoder` on some JSON `Value`. You can send these JSON values
through ports, so that is probably the main time you would use this function.
-}
decodeValue : Decoder a -> Value -> Result String a
decodeValue =
  Native.Json.run


{-| A JSON value.
-}
type alias Value = JsEncode.Value



-- FANCY PRIMITIVES


{-| Ignore the JSON and produce a certain Elm value.

    decodeString (succeed 42) "true"    == Ok 42
    decodeString (succeed 42) "[1,2,3]" == Ok 42
    decodeString (succeed 42) "hello"   == Err ... -- this is not a valid JSON string

This is handy when used with `oneOf` or `andThen`.
-}
succeed : a -> Decoder a
succeed =
  Native.Json.succeed


{-| Ignore the JSON and make the decoder fail. This is handy when used with
`oneOf` or `andThen` where you want to give a custom error message in some
case.

See the [`andThen`](#andThen) docs for an example.
-}
fail : String -> Decoder a
fail =
  Native.Json.fail


{-| Create decoders that depend on previous results. If you are creating
versioned data, you might do something like this:

    info : Decoder Info
    info =
      field "version" int
        |> andThen infoHelp

    infoHelp : Int -> Decoder Info
    infoHelp version =
      case version of
        4 ->
          infoDecoder4

        3 ->
          infoDecoder3

        _ ->
          fail <|
            "Trying to decode info, but version "
            ++ toString version ++ " is not supported."

    -- infoDecoder4 : Decoder Info
    -- infoDecoder3 : Decoder Info
-}
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
  andThen thunk (succeed ())


{-| Do not do anything with a JSON value, just bring it into Elm as a `Value`.
This can be useful if you have particularly crazy data that you would like to
deal with later. Or if you are going to send it out a port and do not care
about its structure.
-}
value : Decoder Value
value =
  Native.Json.decodePrimitive "value"


{-| Decode a `null` value into some Elm value.

    decodeString (null False) "null" == Ok False
    decodeString (null 42) "null"    == Ok 42
    decodeString (null 42) "42"      == Err ..
    decodeString (null 42) "false"   == Err ..

So if you ever see a `null`, this will return whatever value you specified.
-}
null : a -> Decoder a
null =
  Native.Json.decodeNull
