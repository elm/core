module Char
    ( isUpper, isLower, isDigit, isOctDigit, isHexDigit
    , toUpper, toLower, toLocaleUpper, toLocaleLower, KeyCode, toCode, fromCode
    ) where

{-| Functions for working with characters. Character literals are enclosed in
`'a'` pair of single quotes.

# Classification
@docs isUpper, isLower, isDigit, isOctDigit, isHexDigit

# Conversion
@docs toUpper, toLower, toLocaleUpper, toLocaleLower, toCode, fromCode

-}

import Native.Char
import Basics exposing ((&&), (||), (>=), (<=))


isBetween : Char -> Char -> Char -> Bool
isBetween low high char = 
  let code = toCode char
  in
      (code >= toCode low) && (code <= toCode high)


{-| True for upper case letters. -}
isUpper : Char -> Bool
isUpper =
  isBetween 'A' 'Z'


{-| True for lower case letters. -}
isLower : Char -> Bool
isLower =
  isBetween 'a' 'z'


{-| True for ASCII digits `[0-9]`. -}
isDigit : Char -> Bool
isDigit =
  isBetween '0' '9'


{-| True for ASCII octal digits `[0-7]`. -}
isOctDigit : Char -> Bool
isOctDigit =
  isBetween '0' '7'


{-| True for ASCII hexadecimal digits `[0-9a-fA-F]`. -}
isHexDigit : Char -> Bool
isHexDigit char = 
  isDigit char || isBetween 'a' 'f' char || isBetween 'A' 'F' char


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


type alias KeyCode = Int


{-| Convert to unicode. Used with the `Keyboard` library, which expects the
input to be uppercase.
-}
toCode : Char -> KeyCode
toCode =
  Native.Char.toCode


{-| Convert from unicode. -}
fromCode : KeyCode -> Char
fromCode =
  Native.Char.fromCode
