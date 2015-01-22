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
          , test "isLower 'a'" <| assert <| Char.isLower 'a'
          , test "isLower 'A'" <| assert <| not (Char.isLower 'A')
          , test "isLower '0'" <| assert <| not (Char.isLower '0')
          , test "isUpper 'A'" <| assert <| Char.isUpper 'A'
          , test "isUpper 'a'" <| assert <| not (Char.isUpper 'a')
          , test "isUpper '0'" <| assert <| not (Char.isUpper '0')
          , test "isDigit '0'" <| assert <| Char.isDigit '0'
          , test "isDigit 'a'" <| assert <| not (Char.isDigit 'a')
          , test "isDigit 'A'" <| assert <| not (Char.isDigit 'A')
          , test "isOctDigit '0'" <| assert <| Char.isOctDigit '0'
          , test "isOctDigit '7'" <| assert <| Char.isOctDigit '7'
          , test "isOctDigit '8'" <| assert <| not (Char.isOctDigit '8')
          , test "isOctDigit 'a'" <| assert <| not (Char.isOctDigit 'a')
          , test "isHexDigit '0'" <| assert <| Char.isHexDigit '0'
          , test "isHexDigit '9'" <| assert <| Char.isHexDigit '9'
          , test "isHexDigit 'a'" <| assert <| Char.isHexDigit 'a'
          , test "isHexDigit 'A'" <| assert <| Char.isHexDigit 'A'
          , test "isHexDigit 'f'" <| assert <| Char.isHexDigit 'f'
          , test "isHexDigit 'F'" <| assert <| Char.isHexDigit 'F'
          , test "isHexDigit 'g'" <| assert <| not (Char.isHexDigit 'g')
          , test "isHexDigit 'G'" <| assert <| not (Char.isHexDigit 'G')
          ]
