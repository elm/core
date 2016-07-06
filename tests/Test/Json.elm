module Test.Json exposing (tests)

import Basics exposing (..)
import Result exposing (..)
import Json.Decode exposing ((:=))

import ElmTest exposing (..)

tests : Test
tests =
  suite "Json decode"
    [ intTests
    , customTests
    ]

intTests : Test
intTests =
  let testInt val str =
        case Json.Decode.decodeString Json.Decode.int str of
          Ok _ -> assertEqual val True
          Err _ -> assertEqual val False
  in
      suite "Json decode int"
        [ test "whole int" <| testInt True "4"
        , test "-whole int" <| testInt True "-4"
        , test "whole float" <| testInt True "4.0"
        , test "-whole float" <| testInt True "-4.0"
        , test "large int" <| testInt True "1801439850948"
        , test "-large int" <| testInt True "-1801439850948"
        , test "float" <| testInt False "4.2"
        , test "-float" <| testInt False "-4.2"
        , test "Infinity" <| testInt False "Infinity"
        , test "-Infinity" <| testInt False "-Infinity"
        , test "NaN" <| testInt False "NaN"
        , test "-NaN" <| testInt False "-NaN"
        , test "true" <| testInt False "true"
        , test "false" <| testInt False "false"
        , test "string" <| testInt False "\"string\""
        , test "object" <| testInt False "{}"
        , test "null" <| testInt False "null"
        , test "undefined" <| testInt False "undefined"
        , test "Decoder expects object finds array, was crashing runtime." <|
            ( assertEqual
              (Err "Expecting an object but instead got: []")
              (Json.Decode.decodeString
                (Json.Decode.dict Json.Decode.float)
                "[]"
              )
            )
        ]

customTests : Test
customTests =
  let
    jsonString =
      """{ "foo": "bar" }"""

    myDecoder =
      Json.Decode.customDecoder ("foo" := Json.Decode.string) (\_ -> Err "I want to see this message!")

    assertion =
      assertEqual (Err "I want to see this message!") (Json.Decode.decodeString myDecoder jsonString)

  in
    test "custom decoders preserve error messages" assertion

