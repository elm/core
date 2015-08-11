module Test.String (tests) where

import Basics exposing (..)

import List
import Maybe exposing (..)
import String
import Result exposing (..)

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)

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
        [ test "toFloat 42" <| assertEqual (Ok 42) (String.toFloat "42")
        , test "toFloat 42.42" <| assertEqual (Ok 42.42) (String.toFloat "42.42")
        , test "toFloat .42" <| assertEqual (Ok 0.42) (String.toFloat ".42")
        , test "toFloat 42." <| assertEqual (Ok 42) (String.toFloat "42.")
        , test "toFloat ..42" <| assertEqual (Err "could not convert string '..42' to a Float") (String.toFloat "..42")
        , test "toFloat ." <| assertEqual (Err "could not convert string '.' to a Float") (String.toFloat ".")
        , test "toFloat .." <| assertEqual (Err "could not convert string '..' to a Float") (String.toFloat "..")
        , test "toFloat a" <| assertEqual (Err "could not convert string 'a' to a Float") (String.toFloat "a")
        ]

  in
      suite "String" [ simpleTests, combiningTests, conversionTests ]
