module Test.Regex exposing (tests)

import Basics exposing (..)

import Regex exposing (..)

import ElmTest exposing (..)


tests : Test
tests =
  let simpleTests = suite "Simple Stuff"
        [ test "split All" <| assertEqual ["a", "b"] (split All (regex ",") "a,b")
        , test "split" <| assertEqual ["a","b,c"] (split (AtMost 1) (regex ",") "a,b,c")
        , test "split idempotent" <|
            let
                findComma = regex ","
            in
                assertEqual
                    (split (AtMost 1) findComma "a,b,c,d,e")
                    (split (AtMost 1) findComma "a,b,c,d,e")

        , test "find All" <| assertEqual
            ([Match "a" [] 0 1, Match "b" [] 1 2])
            (find All (regex ".") "ab")
        , test "find All" <| assertEqual
            ([Match "" [] 0 1])
            (find All (regex ".*") "")

        , test "replace AtMost 0" <| assertEqual             "The quick brown fox"
            (replace (AtMost 0) (regex "[aeiou]") (\_ -> "") "The quick brown fox")

        , test "replace AtMost 1" <| assertEqual             "Th quick brown fox"
            (replace (AtMost 1) (regex "[aeiou]") (\_ -> "") "The quick brown fox")

        , test "replace AtMost 2" <| assertEqual             "Th qick brown fox"
            (replace (AtMost 2) (regex "[aeiou]") (\_ -> "") "The quick brown fox")

        , test "replace All" <| assertEqual           "Th qck brwn fx"
            (replace All (regex "[aeiou]") (\_ -> "") "The quick brown fox")

        , test "replace using index" <| assertEqual                   "a1b3c"
            (replace All (regex ",") (\match -> toString match.index) "a,b,c")
        ]
  in
      suite "Regex" [ simpleTests ]
