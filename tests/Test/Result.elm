module Test.Result (tests) where

import Basics (..)
import Result
import Result (Result(..))
import String

import ElmTest.Assertion (..)
import ElmTest.Test (..)

isEven n =
  if n % 2 == 0
    then Ok n
    else Err "number is odd"

add3 a b c =
  a + b + c

add4 a b c d =
  a + b + c + d

add5 a b c d e =
  a + b + c + d + e

tests : Test
tests =
  let mapTests = suite "map Tests"
        [
          test "map Ok" <| assertEqual (Ok 3) (Result.map ((+) 1) (Ok 2)),
          test "map Err" <| assertEqual (Err "error") (Result.map ((+) 1) (Err "error"))
        ]
      andThenTests = suite "andThen Tests"
        [
          test "andThen Ok" <| assertEqual (Ok 42) ((String.toInt "42") `Result.andThen` isEven),
          test "andThen first Err" <| assertEqual
            (Err "could not convert string '4.2' to an Int")
            (String.toInt "4.2" `Result.andThen` isEven),
          test "andThen second Err" <| assertEqual
            (Err "number is odd")
            (String.toInt "41" `Result.andThen` isEven)
        ]
  in
    suite "Result Tests"
    [ mapTests
    , andThenTests
    ]
