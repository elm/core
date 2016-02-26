module Main where

import Basics exposing (..)
import Task
import Signal exposing (Signal)

import ElmTest exposing (..)
import Console

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


port runner : Signal (Task.Task x ())
port runner = 
    Console.run (consoleRunner tests)
