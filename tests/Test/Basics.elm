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
        geometryTests = suite "Geometry Tests"
            [ test "radians 0" <| assertEqual 0 (radians 0)
            , test "radians positive" <| assertEqual 5 (radians 5)
            , test "radians negative" <| assertEqual -5 (radians -5)
            , test "degrees 0" <| assertEqual 0 (degrees 0)
            , test "degrees 90" <| assert (abs (1.57 - degrees 90) < 0.01) -- This should test to enough precision to know if anything's breaking
            , test "degrees -145" <| assert (abs (-2.53 - degrees -145) < 0.01) -- This should test to enough precision to know if anything's breaking
            , test "turns 0" <| assertEqual 0 (turns 0)
            , test "turns 8" <| assert (abs (50.26 - turns 8) < 0.01) -- This should test to enough precision to know if anything's breaking
            , test "turns -133" <| assert (abs (-835.66 - turns -133) < 0.01) -- This should test to enough precision to know if anything's breaking
            , test "fromPolar (0, 0)" <| assertEqual (0, 0) (fromPolar (0, 0))
            , test "fromPolar (1, 0)" <| assertEqual (1, 0) (fromPolar (1, 0))
            , test "fromPolar (0, 1)" <| assertEqual (0, 0) (fromPolar (0, 1))
            , test "fromPolar (1, 1)" <| assert (let (x, y) = fromPolar (1, 1) in 0.54 - x < 0.01 && 0.84 - y < 0.01)
            , test "toPolar (0, 0)" <| assertEqual (0, 0) (toPolar (0, 0))
            , test "toPolar (1, 0)" <| assertEqual (1, 0) (toPolar (1, 0))
            , test "toPolar (0, 1)" <| assert (let (r, theta) = toPolar (0, 1) in r == 1 && abs (1.57 - theta) < 0.01)
            , test "toPolar (1, 1)" <| assert (let (r, theta) = toPolar (1, 1) in abs (1.41 - r) < 0.01 && abs (0.78 - theta) < 0.01)
            , test "cos" <| assertEqual 1 (cos 0)
            , test "sin" <| assertEqual 0 (sin 0)
            , test "tan" <| assert (abs (12.67 - tan 17.2) < 0.01)
            , test "acos" <| assert (abs (3.14 - acos -1) < 0.01)
            , test "asin" <| assert (abs (0.30 - asin 0.3) < 0.01)
            , test "atan" <| assert (abs (1.57 - atan 4567.8) < 0.01)
            , test "atan2" <| assert (abs (1.55 - atan2 36 0.65) < 0.01)
            , test "pi" <| assert (abs (3.14 - pi) < 0.01)
            ]
        basicMathTests = suite "Basic Math Tests"
            [ test "add float" <| assertEqual 159 (155.6 + 3.4)
            , test "add int" <| assertEqual 17 ((round 10) + (round 7))
            , test "subtract float" <| assertEqual -6.3 (1 - 7.3)
            , test "subtract int" <| assertEqual 1130 ((round 9432) - (round 8302))
            , test "multiply float" <| assertEqual 435.15 (96.7 * 4.5)
            , test "multiply int" <| assertEqual 90 ((round 10) * (round 9))
            , test "divide float" <| assertEqual 13.175 (527 / 40)
            , test "divide int" <| assertEqual 23 (70 // 3)
            , test "7 `rem` 2" <| assertEqual 1 (7 `rem` 2)
            , test "-1 `rem` 4" <| assertEqual -1 (-1 `rem` 4)
            , test "7 % 2" <| assertEqual 1 (7 % 2)
            , test "-1 % 4" <| assertEqual 3 (-1 % 4)
            , test "3^2" <| assertEqual 9 (3^2)
            , test "sqrt" <| assertEqual 9 (sqrt 81)
            , test "negate 42" <| assertEqual -42 (negate 42)
            , test "negate -42" <| assertEqual 42 (negate -42)
            , test "negate 0" <| assertEqual 0 (negate 0)
            , test "abs -25" <| assertEqual 25 (abs -25)
            , test "abs 76" <| assertEqual 76 (abs 76)
            , test "logBase 10 100" <| assertEqual 2 (logBase 10 100)
            , test "logBase 2 256" <| assertEqual 8 (logBase 2 256)
            , test "e" <| assert (abs (2.72 - e) < 0.01)
            ]
    in
        suite "Basics"
            [ comparison
            , toStringTests
            , geometryTests
            , basicMathTests
            ]
