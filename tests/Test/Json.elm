module Test.Json exposing (tests)

import Basics exposing (..)
import Result exposing (..)
import Json.Decode as Json
import Json.Encode exposing (object, null)
import String
import Test exposing (..)
import Expect


tests : Test
tests =
    describe "Json decode"
        [ intTests
        , customTests
        , equalityTests
        ]


intTests : Test
intTests =
    let
        testInt val str =
            case Json.decodeString Json.int str of
                Ok _ ->
                    Expect.equal val True

                Err _ ->
                    Expect.equal val False
    in
        describe "Json decode int"
            [ test "whole int" <| \() -> testInt True "4"
            , test "-whole int" <| \() -> testInt True "-4"
            , test "whole float" <| \() -> testInt True "4.0"
            , test "-whole float" <| \() -> testInt True "-4.0"
            , test "large int" <| \() -> testInt True "1801439850948"
            , test "-large int" <| \() -> testInt True "-1801439850948"
            , test "float" <| \() -> testInt False "4.2"
            , test "-float" <| \() -> testInt False "-4.2"
            , test "Infinity" <| \() -> testInt False "Infinity"
            , test "-Infinity" <| \() -> testInt False "-Infinity"
            , test "NaN" <| \() -> testInt False "NaN"
            , test "-NaN" <| \() -> testInt False "-NaN"
            , test "true" <| \() -> testInt False "true"
            , test "false" <| \() -> testInt False "false"
            , test "string" <| \() -> testInt False "\"string\""
            , test "object" <| \() -> testInt False "{}"
            , test "null" <| \() -> testInt False "null"
            , test "undefined" <| \() -> testInt False "undefined"
            , test "Decoder expects object finds array, was crashing runtime." <|
                \() ->
                    Expect.equal
                        (Err "Expecting an object but instead got: []")
                        (Json.decodeString (Json.dict Json.float) "[]")
            ]


customTests : Test
customTests =
    let
        jsonString =
            """{ "foo": "bar" }"""

        customErrorMessage =
            "I want to see this message!"

        myDecoder =
            Json.field "foo" Json.string |> Json.andThen (\_ -> Json.fail customErrorMessage)

        assertion =
            case Json.decodeString myDecoder jsonString of
                Ok _ ->
                    Expect.fail "expected `customDecoder` to produce a value of type Err, but got Ok"

                Err message ->
                    if String.contains customErrorMessage message then
                        Expect.pass
                    else
                        Expect.fail <|
                            "expected `customDecoder` to preserve user's error message '"
                                ++ customErrorMessage
                                ++ "', but instead got: "
                                ++ message
    in
        test "customDecoder preserves user error messages" <| \() -> assertion


equalityTests : Test
equalityTests =
    let
        a =
            object [ ( "foo", object [ ( "bar", null ) ] ) ]

        b =
            object []
    in
        describe "equality of values"
            [ test "allows to test deeply nested objects for equality"
                (\() ->
                    a |> Expect.notEqual b
                )
            ]
