module Test.Char (tests) where

import Basics (..)
import Char

import ElmTest.Assertion (..)
import ElmTest.Test (..)

tests : Test
tests = 
    suite "Char" 
          [ test "toUpper" <| assertEqual 'C' <| Char.toUpper 'c'
          , test "toLower" <| assertEqual 'c' <| Char.toLower 'C'
          , test "toLocaleUpper" <| assertEqual 'C' <| Char.toLocaleUpper 'c'
          , test "toLocaleLower" <| assertEqual 'c' <| Char.toLocaleLower 'C'
          , test "toCode 'a'" <| assertEqual 97 <| Char.toCode 'a'
          , test "toCode 'z'" <| assertEqual 122 <| Char.toCode 'z'
          , test "toCode 'A'" <| assertEqual 65 <| Char.toCode 'A'
          , test "toCode 'Z'" <| assertEqual 90 <| Char.toCode 'Z'
          ]
