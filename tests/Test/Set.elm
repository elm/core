module Test.Set exposing (tests)

import Basics exposing (..)
import Maybe exposing (..)
import Set
import Set exposing (Set)
import List
import Test exposing (..)
import Expect


set : Set Int
set =
    Set.fromList <| List.range 1 100


setPart1 : Set Int
setPart1 =
    Set.fromList <| List.range 1 50


setPart2 : Set Int
setPart2 =
    Set.fromList <| List.range 51 100


pred : Int -> Bool
pred x =
    x <= 50


tests : Test
tests =
    let
        queryTests =
            describe "query Tests"
                [ test "size of set of 100 elements" <|
                    \() -> Expect.equal 100 (Set.size set)
                ]

        filterTests =
            describe "filter Tests"
                [ test "Simple filter" <|
                    \() -> Expect.equal setPart1 <| Set.filter pred set
                ]

        partitionTests =
            describe "partition Tests"
                [ test "Simple partition" <|
                    \() -> Expect.equal ( setPart1, setPart2 ) <| Set.partition pred set
                ]

        elemTests =
            describe "element Tests"
                [ test "ADTs" <| \() -> Expect.equal (Set.fromList [Nothing, Just 1, Just 1, Just 2, Nothing]) (Set.fromList [Nothing, Just 1, Just 2])
                , test "records" <| \() -> Expect.equal (Set.fromList [{ x = 0, y = 0 }, { x = 1, y = 2 }, { y = 2, x = 1 }]) (Set.fromList [{ x = 0, y = 0 }, { x = 1, y = 2 }])
                , test "bools" <| \() -> Expect.equal (Set.fromList [False, True, False, True]) (Set.fromList [False, True])
                ]
    in
        describe "Set Tests" [ queryTests, partitionTests, filterTests, elemTests ]
