module Test.Bitwise (tests) where

import Basics (..)
import Bitwise

import ElmTest.Assertion (..)
import ElmTest.Test (..)

tests : Test
tests =
    suite "Bitwise"
        [ suite "and"
            [ test "and with 32 bit integers" <| assertEqual 1 (Bitwise.and 5 3)
            , test "and with 0 as first argument" <| assertEqual 0 (Bitwise.and 0 1450)
            , test "and with 0 as second argument" <| assertEqual 0 (Bitwise.and 274 0)
            , test "and with -1 as first argument" <| assertEqual 2671 (Bitwise.and -1 2671)
            , test "and with -1 as second argument" <| assertEqual 96 (Bitwise.and 96 -1)
            ]
        , suite "or"
            [ test "or with 32 bit integers" <| assertEqual 15 (Bitwise.or 9 14)
            , test "or with 0 as first argument" <| assertEqual 843 (Bitwise.or 0 843)
            , test "or with 0 as second argument" <| assertEqual 19 (Bitwise.or 19 0)
            , test "or with -1 as first argument" <| assertEqual -1 (Bitwise.or -1 2360)
            , test "or with -1 as second argument" <| assertEqual -1 (Bitwise.or 3 -1)
            ]
        , suite "xor"
            [ test "xor with 32 bit integers" <| assertEqual 604 (Bitwise.xor 580 24)
            , test "xor with 0 as first argument" <| assertEqual 56 (Bitwise.xor 0 56)
            , test "xor with 0 as second argument" <| assertEqual -268 (Bitwise.xor -268 0)
            , test "xor with -1 as first argument" <| assertEqual -25 (Bitwise.xor -1 24)
            , test "xor with -1 as second argument" <| assertEqual 25601 (Bitwise.xor -25602 -1)
            ]
        , suite "complement"
            [ test "complement a positive" <| assertEqual -9 (Bitwise.complement 8)
            , test "complement a negative" <| assertEqual 278 (Bitwise.complement -279)
            ]
        , suite "shiftLeft"
            [ test "8 `shiftLeft` 1 == 16" <| assertEqual 16 (Bitwise.shiftLeft 8 1)
            , test "8 `shiftLeft` 2 == 32" <| assertEqual 32 (Bitwise.shiftLeft 8 2)
            ]
        , suite "shiftRight"
            [ test "32 `shiftRight` 1 == 16" <| assertEqual 16 (Bitwise.shiftRight 32 1)
            , test "32 `shiftRight` 2 == 8" <| assertEqual 8 (Bitwise.shiftRight 32 2)
            , test "-32 `shiftRight` 1 == -16" <| assertEqual -16 (Bitwise.shiftRight -32 1)
            ]
        , suite "shiftRightLogical"
            [ test "32 `shiftRightLogical` 1 == 16" <| assertEqual 16 (Bitwise.shiftRightLogical 32 1)
            , test "32 `shiftRightLogical` 2 == 8" <| assertEqual 8 (Bitwise.shiftRightLogical 32 2)
            , test "-32 `shiftRightLogical` 1 == 2147483632" <| assertEqual 2147483632 (Bitwise.shiftRightLogical -32 1)
            ]
        ]
