module Test.Set exposing (tests)

import Basics exposing (..)

import Set
import Set exposing (Set)
import List

import ElmTest exposing (..)

set : Set Int
set = Set.fromList [1..100]

setPart1 : Set Int
setPart1 = Set.fromList [1..50]

setPart2 : Set Int
setPart2 = Set.fromList [51..100]

pred : Int -> Bool
pred x = x <= 50

tests : Test
tests =
    let
      queryTests = suite "query Tests" [test "size of set of 100 elements" <| assertEqual 100 (Set.size set)]
      filterTests = suite "filter Tests" [test "Simple filter" <| assertEqual setPart1 <| Set.filter pred set]
      partitionTests = suite "partition Tests" [test "Simple partition" <| assertEqual (setPart1, setPart2) <| Set.partition pred set]
    in suite "Set Tests" [queryTests, partitionTests, filterTests]
