module Test.Regex exposing (tests)

import Basics exposing (..)
import Regex exposing (..)
import Test exposing (..)
import Expect


tests : Test
tests =
    let
        simpleTests =
            describe "Simple Stuff"
                [ test "split All" <| \() -> Expect.equal [ "a", "b" ] (split All (regex ",") "a,b")
                , test "split" <| \() -> Expect.equal [ "a", "b,c" ] (split (AtMost 1) (regex ",") "a,b,c")
                , test "split idempotent" <|
                    \() ->
                        let
                            findComma =
                                regex ","
                        in
                            Expect.equal
                                (split (AtMost 1) findComma "a,b,c,d,e")
                                (split (AtMost 1) findComma "a,b,c,d,e")
                , test "find All" <|
                    \() ->
                        Expect.equal
                            ([ Match "a" [] 0 1, Match "b" [] 1 2 ])
                            (find All (regex ".") "ab")
                , test "find All" <|
                    \() ->
                        Expect.equal
                            ([ Match "" [] 0 1 ])
                            (find All (regex ".*") "")
                , test "replace AtMost 0" <|
                    \() ->
                        Expect.equal "The quick brown fox"
                            (replace (AtMost 0) (regex "[aeiou]") (\_ -> "") "The quick brown fox")
                , test "replace AtMost 1" <|
                    \() ->
                        Expect.equal "Th quick brown fox"
                            (replace (AtMost 1) (regex "[aeiou]") (\_ -> "") "The quick brown fox")
                , test "replace AtMost 2" <|
                    \() ->
                        Expect.equal "Th qick brown fox"
                            (replace (AtMost 2) (regex "[aeiou]") (\_ -> "") "The quick brown fox")
                , test "replace All" <|
                    \() ->
                        Expect.equal "Th qck brwn fx"
                            (replace All (regex "[aeiou]") (\_ -> "") "The quick brown fox")
                , test "replace using index" <|
                    \() ->
                        Expect.equal "a1b3c"
                            (replace All (regex ",") (\match -> toString match.index) "a,b,c")
                ]
    in
        describe "Regex" [ simpleTests ]
