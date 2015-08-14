module Test.Char (tests) where

import Basics exposing (..)
import Char exposing (..)
import List

import ElmTest.Assertion exposing (..)
import ElmTest.Test exposing (..)


lower = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' ]
upper = [ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' ]
dec = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ]
oct = List.take 8 dec
hexLower = List.take 6 lower
hexUpper = List.take 6 upper
hex = List.append hexLower hexUpper |> List.append dec

lowerCodes = [97..(97 + List.length lower - 1)]
upperCodes = [65..(65 + List.length upper - 1)]
decCodes = [48..(48 + List.length dec - 1)]

oneOf : List a -> a -> Bool
oneOf = flip List.member


tests : Test
tests = suite "Char"
  [ suite "toCode"
      [ test "a-z" <| assertEqual (lowerCodes) (List.map toCode lower)
      , test "A-Z" <| assertEqual (upperCodes) (List.map toCode upper)
      , test "0-9" <| assertEqual (decCodes) (List.map toCode dec)
      ]

  , suite "fromCode"
      [ test "a-z" <| assertEqual (lower) (List.map fromCode lowerCodes)
      , test "A-Z" <| assertEqual (upper) (List.map fromCode upperCodes)
      , test "0-9" <| assertEqual (dec) (List.map fromCode decCodes)
      ]

  , suite "toLocaleLower"
      [ test "a-z" <| assertEqual (lower) (List.map toLocaleLower lower)
      , test "A-Z" <| assertEqual (lower) (List.map toLocaleLower upper)
      , test "0-9" <| assertEqual (dec) (List.map toLocaleLower dec)
      ]

  , suite "toLocaleUpper"
      [ test "a-z" <| assertEqual (upper) (List.map toLocaleUpper lower)
      , test "A-Z" <| assertEqual (upper) (List.map toLocaleUpper upper)
      , test "0-9" <| assertEqual (dec) (List.map toLocaleUpper dec)
      ]

  , suite "toLower"
      [ test "a-z" <| assertEqual (lower) (List.map toLower lower)
      , test "A-Z" <| assertEqual (lower) (List.map toLower upper)
      , test "0-9" <| assertEqual (dec) (List.map toLower dec)
      ]

  , suite "toUpper"
      [ test "a-z" <| assertEqual (upper) (List.map toUpper lower)
      , test "A-Z" <| assertEqual (upper) (List.map toUpper upper)
      , test "0-9" <| assertEqual (dec) (List.map toUpper dec)
      ]

  , suite "isLower"
      [ test "a-z" <| assertEqual (True) (List.all isLower lower)
      , test "A-Z" <| assertEqual (False) (List.any isLower upper)
      , test "0-9" <| assertEqual (False) (List.any isLower dec)
      ]

  , suite "isUpper"
      [ test "a-z" <| assertEqual (False) (List.any isUpper lower)
      , test "A-Z" <| assertEqual (True) (List.all isUpper upper)
      , test "0-9" <| assertEqual (False) (List.any isUpper dec)
      ]

  , suite "isDigit"
      [ test "a-z" <| assertEqual (False) (List.any isDigit lower)
      , test "A-Z" <| assertEqual (False) (List.any isDigit upper)
      , test "0-9" <| assertEqual (True) (List.all isDigit dec)
      ]

  , suite "isHexDigit"
      [ test "a-z" <| assertEqual (List.map (oneOf hex) lower) (List.map isHexDigit lower)
      , test "A-Z" <| assertEqual (List.map (oneOf hex) upper) (List.map isHexDigit upper)
      , test "0-9" <| assertEqual (True) (List.all isHexDigit dec)
      ]

  , suite "isOctDigit"
      [ test "a-z" <| assertEqual (False) (List.any isOctDigit lower)
      , test "A-Z" <| assertEqual (False) (List.any isOctDigit upper)
      , test "0-9" <| assertEqual (List.map (oneOf oct) dec) (List.map isOctDigit dec)
      ]
  ]
