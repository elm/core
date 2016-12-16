module Test.String exposing (tests)

import Basics exposing (..)
import List
import Maybe exposing (..)
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
                , test "reverse unicode" <| \() -> Expect.equal "ma͒n𝌆" (String.reverse "𝌆na͒m")
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
    in
        describe "String" [ simpleTests, combiningTests ]
