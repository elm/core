module Test.Basics.Arithmetic exposing (tests)

import Basics exposing (..)
import Test exposing (..)
import Expect
import Fuzz exposing (float, int)


tests : Test
tests =
    describe "Arithmetic"
        [ describe "+"
            [ fuzz float "adding 0 does nothing" <|
                \num ->
                    (num + 0)
                        |> Expect.equal num
            , fuzzArithmetic2 "it works with negative numbers" <|
                \left right ->
                    (left + -right)
                        |> Expect.equal (left - right)
            , expectCommutative (+)
            , expectAssociative (+)
            ]
        , describe "*"
            [ fuzz float "multiplying by 1 does nothing" <|
                \num ->
                    (num * 1)
                        |> Expect.equal num
            , expectCommutative (*)
            , expectAssociative (*)
            ]
        , describe "-"
            [ fuzz float "subtracting 0 does nothing" <|
                \num ->
                    (num - 0)
                        |> Expect.equal num
            ]
        , describe "/"
            [ fuzz float "dividing by 1 does nothing" <|
                \num ->
                    (num / 1)
                        |> Expect.equal num
            , fuzzArithmetic2 "it undoes multiplication" <|
                \numerator denominator ->
                    if denominator == 0 then
                        -- Skip tests that would be division by 0
                        Expect.pass
                    else
                        ((numerator * denominator) / denominator)
                            |> Expect.equal numerator
            ]
        , describe "//"
            [ fuzz int "dividing by 1 does nothing" <|
                \num ->
                    (num // 1)
                        |> Expect.equal num
            , fuzz2 int int "it undoes multiplication" <|
                \numerator denominator ->
                    if denominator == 0 then
                        -- Skip tests that would be division by 0
                        Expect.pass
                    else
                        ((numerator * denominator) // denominator)
                            |> Expect.equal numerator
            ]
        ]


expectCommutative : (Float -> Float -> Float) -> Test
expectCommutative op =
    fuzzArithmetic2 "it is commutative" <|
        \left right ->
            op left right
                |> Expect.equal (op left right)


expectAssociative : (Float -> Float -> Float) -> Test
expectAssociative op =
    fuzzArithmetic3 "it is associative" <|
        \first second third ->
            op first (op second third)
                |> Expect.equal (op (op first second) third)


fuzzArithmetic2 : String -> (Float -> Float -> Expect.Expectation) -> Test
fuzzArithmetic2 =
    fuzz2 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)


fuzzArithmetic3 : String -> (Float -> Float -> Float -> Expect.Expectation) -> Test
fuzzArithmetic3 =
    fuzz3 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)
