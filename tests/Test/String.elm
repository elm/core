module Test.String (tests) where

import Basics exposing (..)

import List
import Maybe exposing (..)
import Result exposing (..)
import String

import ElmTest exposing (..)

tests : Test
tests =
  let simpleTests = suite "Simple Stuff"
        [ test "is empty" <| assert (String.isEmpty "")
        , test "is not empty" <| assert (not (String.isEmpty ("the world")))
        , test "length" <| assertEqual 11 (String.length "innumerable")
        , test "endsWith" (assert <| String.endsWith "ship" "spaceship")
        , test "reverse" <| assertEqual "desserts" (String.reverse "stressed")
        , test "repeat" <| assertEqual "hahaha" (String.repeat 3 "ha")
        ]

      combiningTests = suite "Combining Strings"
        [ test "uncons non-empty" <| assertEqual (Just ('a',"bc")) (String.uncons "abc")
        , test "uncons empty" <| assertEqual Nothing (String.uncons "")
        , test "append 1" <| assertEqual "butterfly" (String.append "butter" "fly")
        , test "append 2" <| assertEqual "butter" (String.append "butter" "")
        , test "append 3" <| assertEqual "butter" (String.append "" "butter")
        , test "concat" <| assertEqual "nevertheless" (String.concat ["never","the","less"])
        , test "split commas" <| assertEqual ["cat","dog","cow"] (String.split "," "cat,dog,cow")
        , test "split slashes"<| assertEqual ["home","steve","Desktop", ""] (String.split "/" "home/steve/Desktop/")
        , test "join spaces"  <| assertEqual "cat dog cow" (String.join " " ["cat","dog","cow"])
        , test "join slashes" <| assertEqual "home/steve/Desktop" (String.join "/" ["home","steve","Desktop"])
        , test "slice 1" <| assertEqual "c" (String.slice 2 3 "abcd")
        , test "slice 2" <| assertEqual "abc" (String.slice 0 3 "abcd")
        , test "slice 3" <| assertEqual "abc" (String.slice 0 -1 "abcd")
        , test "slice 4" <| assertEqual "cd" (String.slice -2 4 "abcd")
        ]

      conversionTests = suite "Converting Strings"
        [ test "toFloat 1" <| assertEqual (Ok -42.0) (String.toFloat "-42")
        , test "toFloat 2" <| assertEqual (Ok 3.1) (String.toFloat "3.1")
        , test "toFloat 3" <| assertEqual (Ok 30.0) (String.toFloat "3e1")
        , test "toFloat 4" <| assertEqual (Ok -32.0) (String.toFloat "-3.2e+1")
        , test "toFloat 5" <| assertEqual (Ok 0.32) (String.toFloat "+3.2E-1")
        , test "toFloat 6" <| assertEqual "Ok NaN" (toString (String.toFloat "NaN"))
        , test "toFloat 7" <| assertEqual "Ok NaN" (toString (String.toFloat "+NaN"))
        , test "toFloat 8" <| assertEqual "Ok NaN" (toString (String.toFloat "-NaN"))
        , test "toFloat 9" <| assertEqual (Ok (1 / 0)) (String.toFloat "Infinity")
        , test "toFloat 10" <| assertEqual (Ok (1 / 0)) (String.toFloat "+Infinity")
        , test "toFloat 11" <| assertEqual (Ok (-1 / 0)) (String.toFloat "-Infinity")
        , test "toFloat 12" <| assertEqual (Err "could not convert string '' to a Float") (String.toFloat "")
        , test "toFloat 13" <| assertEqual (Err "could not convert string '-' to a Float") (String.toFloat "-")
        , test "toFloat 14" <| assertEqual (Err "could not convert string '31a' to a Float") (String.toFloat "31a")
        , test "toFloat 15" <| assertEqual (Err "could not convert string '.' to a Float") (String.toFloat ".")
        , test "toFloat 16" <| assertEqual (Err "could not convert string '1.' to a Float") (String.toFloat "1.")
        , test "toFloat 17" <| assertEqual (Err "could not convert string '1..1' to a Float") (String.toFloat "1..1")
        , test "toFloat 18" <| assertEqual (Err "could not convert string '.1' to a Float") (String.toFloat ".1")
        , test "toFloat 19" <| assertEqual (Err "could not convert string '- 1' to a Float") (String.toFloat "- 1")
        , test "toFloat 20" <| assertEqual (Err "could not convert string ' -1' to a Float") (String.toFloat " -1")
        , test "toFloat 21" <| assertEqual (Err "could not convert string '-1 ' to a Float") (String.toFloat "-1 ")
        , test "toFloat 22" <| assertEqual (Err "could not convert string '1 2' to a Float") (String.toFloat "1 2")
        ]
  in
      suite "String" [ simpleTests, combiningTests, conversionTests ]
