module Test.List (tests) where

import Basics (..)

import List
import Result (..)
import String

import ElmTest.Assertion (..)
import ElmTest.Test (..)

largeNumber = 100000
trueList = List.repeat largeNumber True
falseList = List.repeat largeNumber False

lessThanThree x = x < 3
isEven n = n % 2 == 0

alice = { name="Alice", height=1.62 }
bob   = { name="Bob"  , height=1.85 }
chuck = { name="Chuck", height=1.76 }

flippedComparison a b =
  case compare a b of
    LT -> GT
    EQ -> EQ
    GT -> LT

tests : Test
tests =
  let partitionTests = suite "partition Tests"
        [ test "simple partition" <| assertEqual ([True],[False]) (List.partition identity [False, True])
        , test "order check" <| assertEqual ([2,1], [5,6]) (List.partition lessThanThree [2,5,6,1])
        , test "partition doc check 1" <| assertEqual ([0,1,2], [3,4,5]) (List.partition lessThanThree [0..5])
        , test "partition doc check 2" <| assertEqual ([0,2,4], [1,3,5]) (List.partition isEven [0..5])
        , test "partition stress test" <| assertEqual (trueList, falseList) (List.partition identity (falseList ++ trueList))
        ]
      unzipTests = suite "unzip Tests"
        [ test "unzip doc check" <| assertEqual ([0,17,1337],[True,False,True]) (List.unzip [(0, True), (17, False), (1337, True)])
        , test "unzip stress test" <| assertEqual (trueList, falseList) (List.unzip (List.map2 (,) trueList falseList))
        ]
      concatTests = suite "concat Tests"
        [ test "concat doc check 1" <| assertEqual [1,2,3,4,5] (List.concat [[1,2],[3],[4,5]])
        ]
      intersperseTests = suite "intersperse Tests"
        [ test "intersperse doc check" <| assertEqual ["turtles","on","turtles","on","turtles"] (List.intersperse "on" ["turtles","turtles","turtles"])
        , test "intersperse stress test" <| assertEqual (List.tail <| List.concat <| List.map2 (\x y -> [x,y]) falseList trueList) (List.intersperse False trueList)
        ]
      zipTests = suite "map2 Tests"
        [ test "zip doc check 1" <| assertEqual [(1,6),(2,7)] (List.map2 (,) [1,2,3] [6,7])
        ]
      filterMapTests = suite "filterMap Tests"
        [ test "filterMap doc check" <| assertEqual [3,5] (List.filterMap (toMaybe << String.toInt) ["3","4.0","5","hats"])
        ]
      concatMapTests = suite "concatMap Tests"
        [ test "simple concatMap check" <| assertEqual [1,1,2,2] (List.concatMap (List.repeat 2) [1,2])
        ]
      indexedMapTests = suite "indexedMap Tests"
        [ test "indexedMap doc check" <| assertEqual [(0,"Tom"),(1,"Sue"),(2,"Bob")] (List.indexedMap (,) ["Tom", "Sue", "Bob"])
        ]
      sortTests = suite "sort Tests"
        [ test "sort doc check" <| assertEqual [1,3,5] (List.sort [3,1,5])
        , test "sort string check" <| assertEqual ["a","c","e"] (List.sort ["c","a","e"])
        ]
      sortByTests = suite "sortBy Tests"
        [ test "sortBy doc check" <| assertEqual ["cat","mouse"] (List.sortBy String.length ["mouse","cat"])
        , test "sortby derived property check 1" <| assertEqual [alice,bob,chuck] (List.sortBy .name [chuck,alice,bob])
        , test "sortby derived property check 2" <| assertEqual [alice,chuck,bob] (List.sortBy .height [chuck,alice,bob])
        ]
      sortWithTests = suite "sortWith Tests"
        [ test "sortWith doc check" <| assertEqual [5,4,3,2,1] (List.sortWith flippedComparison [1..5])
        ]
  in
      suite "List Tests"
      [ partitionTests
      , unzipTests
      , concatTests
      , intersperseTests
      , zipTests
      , filterMapTests
      , concatMapTests
      , indexedMapTests
      , sortTests
      , sortByTests
      , sortWithTests
      ]
