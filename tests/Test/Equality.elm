module Test.Equality exposing (tests)

import Basics exposing (..)
import Maybe exposing (..)

import ElmTest exposing (..)

type Different
    = A String
    | B (List Int)

tests : Test
tests =
  let diffTests = suite "ADT equality"
        [ test "As eq" <| assert (A "a" == A "a")
        , test "Bs eq" <| assert (B [1] == B [1])
        , test "A left neq" <| assert (A "a" /= B [1])
        , test "A left neq" <| assert (B [1] /= A "a")
        ]
      recordTests = suite "Record equality"
        [ test "empty same" <| assert ({} == {})
        , test "ctor same" <| assert ({field = Just 3} == {field = Just 3})
        , test "ctor same, special case" <| assert ({ctor = Just 3} == {ctor = Just 3})
        , test "ctor diff" <| assert ({field = Just 3} /= {field = Nothing})
        , test "ctor diff, special case" <| assert ({ctor = Just 3} /= {ctor = Nothing})
        ]
  in
      suite "Equality Tests" [diffTests, recordTests]
