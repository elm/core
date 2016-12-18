module Test.Basics.Arithmetic exposing (tests)

import Basics exposing (..)
import Test exposing (..)
import Expect
import Fuzz exposing (float)


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
            , fuzzArithmetic2 "it is commutative" <|
                \left right ->
                    (left + right)
                        |> Expect.equal (right + left)
            , fuzzArithmetic3 "it is associative" <|
                \first second third ->
                    (first + second + third)
                        |> Expect.equal ((first + second) + third)
            ]
        , describe "*"
            [ fuzz float "multiplying by 1 does nothing" <|
                \num ->
                    (num * 1)
                        |> Expect.equal num
            , fuzzArithmetic2 "it is commutative" <|
                \left right ->
                    (left * right)
                        |> Expect.equal (right * left)
            , fuzzArithmetic3 "it is associative" <|
                \first second third ->
                    (first * second * third)
                        |> Expect.equal ((first * second) * third)
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
        ]


fuzzArithmetic2 : String -> (Float -> Float -> Expect.Expectation) -> Test
fuzzArithmetic2 =
    fuzz2 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)


fuzzArithmetic3 : String -> (Float -> Float -> Float -> Expect.Expectation) -> Test
fuzzArithmetic3 =
    fuzz3 (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int) (Fuzz.map toFloat Fuzz.int)
