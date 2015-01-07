module Test.Basics (tests) where

import Basics (..)
import ElmTest.Assertion (..)
import ElmTest.Test (..)

tests : Test
tests =
    let comparison =
            suite "Comparison"
            [ test "max" <| assertEqual 42 (max 32 42)
            , test "min" <| assertEqual 42 (min 91 42)
            , test "clamp low" <| assertEqual 10 (clamp 10 20 5)
            , test "clamp mid" <| assertEqual 15 (clamp 10 20 15)
            , test "clamp high" <| assertEqual 20 (clamp 10 20 25)
            ]
        toStringTests = suite "toString Tests"
            [ test "toString Int" <| assertEqual "42" (toString 42)
            , test "toString Float" <| assertEqual "42.52" (toString 42.52)
            , test "toString Char" <| assertEqual "'c'" (toString 'c')
            , test "toString Char single quote" <| assertEqual "'\\''" (toString '\'')
            , test "toString Char double quote" <| assertEqual "'\"'" (toString '"')
            , test "toString String single quote" <| assertEqual "\"not 'escaped'\"" (toString "not 'escaped'")
            , test "toString String double quote" <| assertEqual "\"are \\\"escaped\\\"\"" (toString "are \"escaped\"")
            ]

    in
        suite "Basics"
            [ comparison
            , toStringTests
            ]
