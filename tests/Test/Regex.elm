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
        , test "find All" <| assertEqual
            ([Match "a" [] 0 1, Match "b" [] 1 2])
            (find All (regex ".") "ab")
        , test "find All" <| assertEqual
            ([Match "" [] 0 1])
            (find All (regex ".*") "")
        ]
  in
      suite "Regex" [ simpleTests ]
