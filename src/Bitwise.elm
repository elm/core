module Bitwise exposing
  ( and, or, xor, complement
  , leftShift, rightShift, logicalRightShift
  )

{-| Library for [bitwise operations](http://en.wikipedia.org/wiki/Bitwise_operation).

# Basic Operations
@docs and, or, xor, complement

# Bit Shifts
@docs leftShift, rightShift, logicalRightShift
-}

import Native.Bitwise


{-| Bitwise AND
-}
and : Int -> Int -> Int
and =
  Native.Bitwise.and


{-| Bitwise OR
-}
or : Int -> Int -> Int
or =
  Native.Bitwise.or


{-| Bitwise XOR
-}
xor : Int -> Int -> Int
xor =
  Native.Bitwise.xor


{-| Flip each bit individually, often called bitwise NOT
-}
complement : Int -> Int
complement =
  Native.Bitwise.complement


{-| Shift bits to the left by a given offset, filling new bits with zeros.
This can be used to multiply numbers by powers of two.

    leftShift 1 5 == 10
    leftShift 5 1 == 32
-}
leftShift : Int -> Int -> Int
leftShift =
  Native.Bitwise.leftShift


{-| Shift bits to the right by a given offset, filling new bits with
whatever is the topmost bit. This can be used to divide numbers by powers of two.

    rightShift 1  32 == 16
    rightShift 2  32 == 8
    rightShift 1 -32 == -16

This is called an [arithmetic right shift][ars], often written (>>), and
sometimes called a sign-propagating right shift because it fills empty spots
with copies of the highest bit.

[ars]: http://en.wikipedia.org/wiki/Bitwise_operation#Arithmetic_shift
-}
rightShift : Int -> Int -> Int
rightShift =
  Native.Bitwise.shiftRight


{-| Shift bits to the right by a given offset, filling new bits with zeros.

    logicalRightShift 1  32 == 16
    logicalRightShift 2  32 == 8
    logicalRightShift 1 -32 == 2147483632

This is called an [logical right shift][lrs], often written (>>>), and
sometimes called a zero-fill right shift because it fills empty spots with
zeros.

[lrs]: http://en.wikipedia.org/wiki/Bitwise_operation#Logical_shift
-}
logicalRightShift : Int -> Int -> Int
logicalRightShift =
  Native.Bitwise.logicalRightShift

