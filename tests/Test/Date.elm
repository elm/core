module Test.Date exposing (tests)

import Date exposing (..)
import Basics exposing (..)

import ElmTest exposing (..)

tests : Test
tests =
  let equalityTests = suite "Equality"
        [ test "same dates"      <| assertEqual (Date.fromString "2/7/1992") (Date.fromString "2/7/1992")
        , test "different dates" <| assertNotEqual (Date.fromString "11/16/1995") (Date.fromString "2/7/1992")
        ]
  in
      suite "Date" [ equalityTests ]
