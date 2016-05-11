module Main exposing (..)

import Basics exposing (..)
import ElmTest exposing (..)

import Test.Array as Array
import Test.Basics as Basics
import Test.Bitwise as Bitwise
import Test.Char as Char
import Test.CodeGen as CodeGen
import Test.Dict as Dict
import Test.Equality as Equality
import Test.Json as Json
import Test.List as List
import Test.Result as Result
import Test.Set as Set
import Test.String as String
import Test.Regex as Regex

tests : Test
tests =
    suite "Elm Standard Library Tests"
        [ Array.tests
        , Basics.tests
        , Bitwise.tests
        , Char.tests
        , CodeGen.tests
        , Dict.tests
        , Equality.tests
        , Json.tests
        , List.tests
        , Result.tests
        , Set.tests
        , String.tests
        , Regex.tests
        ]


main =
    runSuite tests
