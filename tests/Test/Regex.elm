module Test.Regex (tests) where

import Basics exposing (..)
import Result exposing (Result(..))

import Regex exposing (..)

import ElmTest exposing (..)


tests : Test
tests =
  let simpleTests = suite "Simple Stuff"
        [ test "valid regex string" <| assertEqual True (case regex "[aeiou]" of
            Ok _ -> True
            Err _ -> False)
        , test "invalid regex string" <| assertEqual True (case regex "[aeiou" of
            Ok _ -> False
            Err _ -> True)
        , test "split All" <| assertEqual ["a", "b"] (split All (comma) "a,b")
        , test "split" <| assertEqual ["a","b,c"] (split (AtMost 1) (comma) "a,b,c")
        , test "find All" <| assertEqual
            ([Match "a" [] 0 1, Match "b" [] 1 2])
            (find All (case regex "." of Ok v -> v) "ab")
        , test "find All" <| assertEqual
            ([Match "" [] 0 1])
            (find All (case regex ".*" of Ok v -> v) "")

        , test "replace AtMost 0" <| assertEqual             "The quick brown fox"
            (replace (AtMost 0) (vowels) (\_ -> "") "The quick brown fox")

        , test "replace AtMost 1" <| assertEqual             "Th quick brown fox"
            (replace (AtMost 1) (vowels) (\_ -> "") "The quick brown fox")

        , test "replace AtMost 2" <| assertEqual             "Th qick brown fox"
            (replace (AtMost 2) (vowels) (\_ -> "") "The quick brown fox")

        , test "replace All" <| assertEqual           "Th qck brwn fx"
            (replace All (vowels) (\_ -> "") "The quick brown fox")
        ]
      
      vowels = case regex "[aeiou]" of Ok x -> x
      comma = case regex "," of Ok x -> x
  in
      suite "Regex" [ simpleTests ]