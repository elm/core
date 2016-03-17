module Test.Equality (tests) where

import Basics exposing (..)
import Maybe exposing (..)
import Json.Encode as JE

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
        , test "ctor same" <| assert ({ctor = Just 3} == {ctor = Just 3})
        , test "ctor diff" <| assert ({ctor = Just 3} /= {ctor = Nothing})
        ]
      jsonTests = suite "Json equality"
        [ test "empty obj same" <| assert (JE.object [] == JE.object [])
        , test "null same" <| assert (JE.null == JE.null)
        , test "null neq primitve" <| assert (JE.null /= JE.int 1)
        , test "primitve neq null" <| assert (JE.int 1 /= JE.null)
        , test "null neq empty obj" <| assert (JE.null /= JE.object [])
        , test "empty obj neq null" <| assert (JE.object [] /= JE.null)
        , test "null neq obj" <| assert (JE.null /= JE.object [("a", JE.int 3)])
        , test "obj neq null" <| assert (JE.object [("a", JE.int 3)] /= JE.null)
        , test "null neq array" <| assert (JE.null /= JE.list [])
        , test "array neq null" <| assert (JE.list [] /= JE.null)
        , test "primitive same" <| assert (JE.int 3 == JE.int 3)
        , test "obj same" <| assert (JE.object [("a", JE.int 3)] == JE.object [("a", JE.int 3)])
        , test "obj diff key" <| assert (JE.object [("a", JE.int 3)] /= JE.object [("b", JE.int 3)])
        , test "obj diff val" <| assert (JE.object [("a", JE.int 3)] /= JE.object [("b", JE.int 4)])
        , test "array same" <| assert (JE.list [JE.int 3] == JE.list [JE.int 3] )
        ]
  in
      suite "Equality Tests" [diffTests, recordTests, jsonTests]
