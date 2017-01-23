module Test.String exposing (tests)

import Basics exposing (..)
import List
import Maybe exposing (..)
import Result exposing (Result(..))
import String
import Test exposing (..)
import Expect


tests : Test
tests =
    let
        simpleTests =
            describe "Simple Stuff"
                [ test "is empty" <| \() -> Expect.equal True (String.isEmpty "")
                , test "is not empty" <| \() -> Expect.equal True (not (String.isEmpty ("the world")))
                , test "length" <| \() -> Expect.equal 11 (String.length "innumerable")
                , test "endsWith" <| \() -> Expect.equal True <| String.endsWith "ship" "spaceship"
                , test "reverse" <| \() -> Expect.equal "desserts" (String.reverse "stressed")
                , test "repeat" <| \() -> Expect.equal "hahaha" (String.repeat 3 "ha")
                , test "indexes" <| \() -> Expect.equal [ 0, 2 ] (String.indexes "a" "aha")
                , test "empty indexes" <| \() -> Expect.equal [] (String.indexes "" "aha")
                ]

        combiningTests =
            describe "Combining Strings"
                [ test "uncons non-empty" <| \() -> Expect.equal (Just ( 'a', "bc" )) (String.uncons "abc")
                , test "uncons empty" <| \() -> Expect.equal Nothing (String.uncons "")
                , test "append 1" <| \() -> Expect.equal "butterfly" (String.append "butter" "fly")
                , test "append 2" <| \() -> Expect.equal "butter" (String.append "butter" "")
                , test "append 3" <| \() -> Expect.equal "butter" (String.append "" "butter")
                , test "concat" <| \() -> Expect.equal "nevertheless" (String.concat [ "never", "the", "less" ])
                , test "split commas" <| \() -> Expect.equal [ "cat", "dog", "cow" ] (String.split "," "cat,dog,cow")
                , test "split slashes" <| \() -> Expect.equal [ "home", "steve", "Desktop", "" ] (String.split "/" "home/steve/Desktop/")
                , test "join spaces" <| \() -> Expect.equal "cat dog cow" (String.join " " [ "cat", "dog", "cow" ])
                , test "join slashes" <| \() -> Expect.equal "home/steve/Desktop" (String.join "/" [ "home", "steve", "Desktop" ])
                , test "slice 1" <| \() -> Expect.equal "c" (String.slice 2 3 "abcd")
                , test "slice 2" <| \() -> Expect.equal "abc" (String.slice 0 3 "abcd")
                , test "slice 3" <| \() -> Expect.equal "abc" (String.slice 0 -1 "abcd")
                , test "slice 4" <| \() -> Expect.equal "cd" (String.slice -2 4 "abcd")
                ]

        intTests =
            describe "String.toInt"
                [ goodInt "1234" 1234
                , goodInt "+1234" 1234
                , goodInt "-1234" -1234
                , badInt "1.34"
                , badInt "1e31"
                , badInt "123a"
                , goodInt "0123" 123
                , goodInt "0x001A" 26
                , goodInt "0x001a" 26
                , goodInt "0xBEEF" 48879
                , badInt "0x12.0"
                , badInt "0x12an"
                ]

        floatTests =
            describe "String.toFloat"
                [ goodFloat "123" 123
                , goodFloat "3.14" 3.14
                , goodFloat "+3.14" 3.14
                , goodFloat "-3.14" -3.14
                , goodFloat "0.12" 0.12
                , goodFloat ".12" 0.12
                , goodFloat "1e-42" 1e-42
                , goodFloat "6.022e23" 6.022e23
                , goodFloat "6.022E23" 6.022e23
                , goodFloat "6.022e+23" 6.022e23
                , badFloat "6.022e"
                , badFloat "6.022n"
                , badFloat "6.022.31"
                ]
    in
        describe "String" [ simpleTests, combiningTests, intTests, floatTests ]



-- NUMBER HELPERS


goodInt : String -> Int -> Test
goodInt str int =
    test str <| \_ ->
        Expect.equal (Ok int) (String.toInt str)


badInt : String -> Test
badInt str =
    test str <| \_ ->
        Expect.equal
            (Err ("could not convert string '" ++ str ++ "' to an Int"))
            (String.toInt str)


goodFloat : String -> Float -> Test
goodFloat str float =
    test str <| \_ ->
        Expect.equal (Ok float) (String.toFloat str)


badFloat : String -> Test
badFloat str =
    test str <| \_ ->
        Expect.equal
            (Err ("could not convert string '" ++ str ++ "' to a Float"))
            (String.toFloat str)
