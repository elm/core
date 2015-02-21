module Main where

import Basics (..)
import Signal (..)

import ElmTest.Assertion as A
import ElmTest.Run as R
import ElmTest.Runner.Console (runDisplay)
import ElmTest.Test (..)
import IO.IO (..)
import IO.Runner (Request, Response)
import IO.Runner as Run

import Test.Array as Array
import Test.Basics as Basics
import Test.Bitwise as Bitwise
import Test.Char as Char
import Test.CodeGen as CodeGen
import Test.Dict as Dict
import Test.Equality as Equality
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
