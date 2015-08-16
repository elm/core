module Main where

import Basics exposing (..)
import Signal exposing (..)

import ElmTest.Assertion as A
import ElmTest.Run as R
import ElmTest.Runner.Console exposing (runDisplay)
import ElmTest.Test exposing (..)
import IO.IO exposing (..)
import IO.Runner exposing (Request, Response)
import IO.Runner as Run

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
import Test.Trampoline as Trampoline

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
    , Trampoline.tests
    ]

console : IO ()
console = runDisplay tests

port requests : Signal Request
port requests = Run.run responses console

port responses : Signal Response
