module Test.Regex (tests) where

import Basics (..)

import Regex (..)

import ElmTest.Assertion (..)
import ElmTest.Test (..)

tests : Test
tests =
  let simpleTests = suite "Simple Stuff"
        [ test "split All" <| assertEqual ["a", "b"] (split All (regex ",") "a,b")
        , test "split" <| assertEqual ["a","b,c"] (split (AtMost 1) (regex ",") "a,b,c")
        ]
  in
      suite "Regex" [ simpleTests ]
