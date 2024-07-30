module Char exposing
  ( Char
  , isUpper, isLower, isAlpha, isAlphaNum
  , isDigit, isOctDigit, isHexDigit
  , toUpper, toLower, toLocaleUpper, toLocaleLower
  , toCode, fromCode
  )

{-| Functions for working with characters. Character literals are enclosed in
`'a'` pair of single quotes.

# Characters
@docs Char

# ASCII Letters
@docs isUpper, isLower, isAlpha, isAlphaNum

# Digits
@docs isDigit, isOctDigit, isHexDigit

# Conversion
@docs toUpper, toLower, toLocaleUpper, toLocaleLower

# Unicode Code Points
@docs toCode, fromCode
-}

import Basics exposing (Bool, Int, (&&), (||), (>=), (<=))
import Elm.Kernel.Char



-- CHAR


{-| A `Char` is a single [unicode][u] character:

    'a'
    '0'
    'Z'
    '?'
    '"'
    'Σ'
    '🙈'

    '\t'
    '\"'
    '\''
    '\u{1F648}' -- '🙈'

**Note 1:** You _cannot_ use single quotes around multiple characters like in
JavaScript. This is how we distinguish [`String`](String#String) and `Char`
values in syntax.

**Note 2:** You can use the unicode escapes from `\u{0000}` to `\u{10FFFF}` to
represent characters by their code point. You can also include the unicode
characters directly. Using the escapes can be better if you need one of the
many whitespace characters with different widths.

[u]: https://en.wikipedia.org/wiki/Unicode
-}
type Char = Char -- NOTE: The compiler provides the real implementation.



-- CLASSIFICATION


{-| Detect upper case ASCII characters.

    isUpper 'A' == True
    isUpper 'B' == True
    ...
    isUpper 'Z' == True

    isUpper '0' == False
    isUpper 'a' == False
    isUpper '-' == False
    isUpper 'Σ' == False
-}
isUpper : Char -> Bool
isUpper char =
  isUpperCode (toCode char)


isUpperCode : Int -> Bool
isUpperCode code =
  code <= 0x5A && 0x41 <= code


{-| Detect lower case ASCII characters.

    isLower 'a' == True
    isLower 'b' == True
    ...
    isLower 'z' == True

    isLower '0' == False
    isLower 'A' == False
    isLower '-' == False
    isLower 'π' == False
-}
isLower : Char -> Bool
isLower char =
  isLowerCode (toCode char)


isLowerCode : Int -> Bool
isLowerCode code =
  0x61 <= code && code <= 0x7A


{-| Detect upper case and lower case ASCII characters.

    isAlpha 'a' == True
    isAlpha 'b' == True
    isAlpha 'E' == True
    isAlpha 'Y' == True

    isAlpha '0' == False
    isAlpha '-' == False
    isAlpha 'π' == False
-}
isAlpha : Char -> Bool
isAlpha char =
  let
    code =
      toCode char
  in
    isLowerCode code || isUpperCode code


{-| Detect upper case and lower case ASCII characters.

    isAlphaNum 'a' == True
    isAlphaNum 'b' == True
    isAlphaNum 'E' == True
    isAlphaNum 'Y' == True
    isAlphaNum '0' == True
    isAlphaNum '7' == True

    isAlphaNum '-' == False
    isAlphaNum 'π' == False
-}
isAlphaNum : Char -> Bool
isAlphaNum char =
  let
    code =
      toCode char
  in
    isLowerCode code || isUpperCode code || isDigitCode code


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
  isDigitCode (toCode char)


isDigitCode : Int -> Bool
isDigitCode code =
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


{-| Detect hexadecimal digits `0123456789abcdefABCDEF`
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
  Elm.Kernel.Char.toUpper


{-| Convert to lower case. -}
toLower : Char -> Char
toLower =
  Elm.Kernel.Char.toLower


{-| Convert to upper case, according to any locale-specific case mappings. -}
toLocaleUpper : Char -> Char
toLocaleUpper =
  Elm.Kernel.Char.toLocaleUpper


{-| Convert to lower case, according to any locale-specific case mappings. -}
toLocaleLower : Char -> Char
toLocaleLower =
  Elm.Kernel.Char.toLocaleLower


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
  Elm.Kernel.Char.toCode


{-| Convert a Unicode [code point][cp] to a character.

    fromCode 65      == 'A'
    fromCode 66      == 'B'
    fromCode 0x6728  == '木'
    fromCode 0x1D306 == '𝌆'
    fromCode 0x1F603 == '😃'
    fromCode -1      == '�'

The full range of unicode is from `0` to `0x10FFFF`. With numbers outside that
range, you get [the replacement character][fffd].

[cp]: https://en.wikipedia.org/wiki/Code_point
[fffd]: https://en.wikipedia.org/wiki/Specials_(Unicode_block)#Replacement_character
-}
fromCode : Int -> Char
fromCode =
  Elm.Kernel.Char.fromCode
