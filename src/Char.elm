module Char exposing
  ( isUpper, isLower, isDigit, isOctDigit, isHexDigit
  , toUpper, toLower, toLocaleUpper, toLocaleLower
  , toCode, fromCode
  )

{-| Functions for working with characters. Character literals are enclosed in
`'a'` pair of single quotes.

# Classification
@docs isUpper, isLower, isDigit, isOctDigit, isHexDigit

# Conversion
@docs toUpper, toLower, toLocaleUpper, toLocaleLower

# Unicode Code Points
@docs toCode, fromCode
-}

import Native.Char
import Basics exposing ((&&), (||), (>=), (<=))



-- CLASSIFICATION


{-| Detect upper case ASCII characters.

    isUpper 'A' == True
    isUpper 'B' == True
    ...
    isUpper 'Z' == True

    isUpper '0' == False
    isUpper 'a' == False
    isUpper 'Σ' == False
-}
isUpper : Char -> Bool
isUpper char =
  let
    code =
      toCode char
  in
    code <= 0x5A && 0x41 <= code


{-| Detect lower case ASCII characters.

    isLower 'a' == True
    isLower 'b' == True
    ...
    isLower 'z' == True

    isLower '0' == False
    isLower 'A' == False
    isLower 'π' == False
-}
isLower : Char -> Bool
isLower char =
  let
    code =
      toCode char
  in
    0x61 <= code && code <= 0x7A


{-| Detect digits `0123456789`

    isDigit '0' == True
    isDigit '1' == True
    ...
    isDigit '9' == True

    isDigit 'a' == False
    isDigit 'b' == False
    isDigit 'A' == False
-}
isDigit : Char -> Bool
isDigit char =
  let
    code =
      toCode char
  in
    code <= 0x39 && 0x30 <= code


{-| Detect octal digits `01234567`

    isOctDigit '0' == True
    isOctDigit '1' == True
    ...
    isOctDigit '7' == True

    isOctDigit '8' == False
    isOctDigit 'a' == False
    isOctDigit 'A' == False
-}
isOctDigit : Char -> Bool
isOctDigit char =
  let
    code =
      toCode char
  in
    code <= 0x37 && 0x30 <= code


{-| Detect hexidecimal digits `0123456789abcdefABCDEF`
-}
isHexDigit : Char -> Bool
isHexDigit char =
  let
    code =
      toCode char
  in
    (0x30 <= code && code <= 0x39)
    || (0x41 <= code && code <= 0x46)
    || (0x61 <= code && code <= 0x66)



-- CONVERSIONS


{-| Convert to upper case. -}
toUpper : Char -> Char
toUpper =
  Native.Char.toUpper


{-| Convert to lower case. -}
toLower : Char -> Char
toLower =
  Native.Char.toLower


{-| Convert to upper case, according to any locale-specific case mappings. -}
toLocaleUpper : Char -> Char
toLocaleUpper =
  Native.Char.toLocaleUpper


{-| Convert to lower case, according to any locale-specific case mappings. -}
toLocaleLower : Char -> Char
toLocaleLower =
  Native.Char.toLocaleLower


{-| Convert to the corresponding Unicode [code point][cp].

[cp]: https://en.wikipedia.org/wiki/Code_point

    toCode 'A' == 65
    toCode 'B' == 66
    toCode '木' == 0x6728
    toCode '𝌆' == 0x1D306
    toCode '😃' == 0x1F603
-}
toCode : Char -> Int
toCode =
  Native.Char.toCode


{-| Convert a Unicode [code point][cp] to a character.

[cp]: https://en.wikipedia.org/wiki/Code_point

    fromCode 65      == 'A'
    fromCode 66      == 'B'
    fromCode 0x6728  == '木'
    fromCode 0x1D306 == '𝌆'
    fromCode 0x1F603 == '😃'
-}
fromCode : Int -> Char
fromCode =
  Native.Char.fromCode
