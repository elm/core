module Test.Equality exposing (tests)

import Basics exposing (..)
import Expect exposing (..)
import Fuzz exposing (..)
import List
import Maybe exposing (Maybe(..))
import Test exposing (..)


type Different
    = A String
    | B (List Int)


tests : Test
tests =
    let
        diffTests =
            describe "ADT equality"
                [ test "As eq" <| \() -> Expect.equal True (A "a" == A "a")
                , test "Bs eq" <| \() -> Expect.equal True (B [ 1 ] == B [ 1 ])
                , test "A left neq" <| \() -> Expect.equal True (A "a" /= B [ 1 ])
                , test "A right neq" <| \() -> Expect.equal True (B [ 1 ] /= A "a")
                ]

        recordTests =
            describe "Record equality"
                [ test "empty same" <| \() -> Expect.equal True ({} == {})
                , test "ctor same" <| \() -> Expect.equal True ({ field = Just 3 } == { field = Just 3 })
                , test "ctor same, special case" <| \() -> Expect.equal True ({ ctor = Just 3 } == { ctor = Just 3 })
                , test "ctor diff" <| \() -> Expect.equal True ({ field = Just 3 } /= { field = Nothing })
                , test "ctor diff, special case" <| \() -> Expect.equal True ({ ctor = Just 3 } /= { ctor = Nothing })
                ]

        listTests =
            describe "List equality"
                [ fuzz2 (Fuzz.intRange 100 10000) (Fuzz.intRange 100 10000) "Simple comparison" <|
                    \size1 size2 ->
                        Expect.equal
                            (size1 == size2)
                            (List.range 0 size1 == List.range 0 size2)
                ]
    in
        describe "Equality Tests" [ diffTests, recordTests, listTests, nestingThresholdTest, fuzzedNestingThreshold ]


{-https://github.com/elm/core/issues/1011-}
nestingThreshold = 100 --keep in sync with src/Elm/Kernel/Utils.js _Utils_eqHelp
buffer = 2


nestingThresholdTest : Test
nestingThresholdTest =
    let
        oneThing = { f1 = True , f2 = { f3 = False } }
        range = List.range (nestingThreshold - buffer) (nestingThreshold + buffer)
        lengthPairsToTest = List.concatMap (\i -> List.map (\j -> ( i, j )) range) range
        check desc e (l1, l2) =
            test ("compare lists of " ++ desc ++ " of length " ++ String.fromInt l1 ++ " and " ++ String.fromInt l2) <| \() ->
                Expect.equal
                    (l1 == l2)
                    (List.repeat l1 e == List.repeat l2 e)
    in
    describe "Nesting Threshold" <|
        (List.map (check "True" True) lengthPairsToTest) ++
        (List.map (check "an object" oneThing) lengthPairsToTest)


fuzzedNestingThreshold : Test
fuzzedNestingThreshold =
    let
        oneThing = { f1 = True , f2 = { f3 = False } }
    in
    describe "fuzzed nesting threshold tests"
    [ oneFuzzedNestingThreshold "True" <| constant True
    , oneFuzzedNestingThreshold "a string" <| constant "a string"
    , oneFuzzedNestingThreshold "13" <| constant 13
    , oneFuzzedNestingThreshold "-4.75" <| constant -4.75
    , oneFuzzedNestingThreshold "Nothing" <| constant <| Nothing
    , oneFuzzedNestingThreshold "Just something" <| constant <| Just "something"
    , oneFuzzedNestingThreshold "oneThing" <| constant oneThing
    , oneFuzzedNestingThreshold "Different" <| oneOf [ constant <| A "A", map B <| list int ]
    ]


oneFuzzedNestingThreshold : String -> Fuzzer a -> Test
oneFuzzedNestingThreshold   name      element    =
    let
        prefixSize = intRange (nestingThreshold - buffer) (nestingThreshold + buffer)
        suffixSize = intRange 0 (buffer * 2)
        prefix = map2 List.repeat prefixSize element
        suffix = map2 List.repeat suffixSize element
    in
    fuzz (tuple3 (prefix, suffix, suffix)) ("fuzzed nesting threshold " ++ name) (oneNestingTest List.append)


oneNestingTest : (a -> b -> c) -> (a           , b        , b        ) -> Expectation
oneNestingTest   affixFn          (commonPrefix, suffixOne, suffixTwo)   =
    Expect.equal
        (suffixOne == suffixTwo)
        ((affixFn commonPrefix suffixOne) == (affixFn commonPrefix suffixTwo))
