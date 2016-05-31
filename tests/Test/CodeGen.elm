module Test.CodeGen exposing (tests)

import Basics exposing (..)
import ElmTest exposing (..)

import Maybe
import Maybe exposing (..)


type Wrapper a = Wrapper a


casePrime m' =
    case m' of
        Just x -> x
        Nothing -> 0

patternPrime =
    case Just 42 of
        Just x' -> x'
        Nothing -> 0

letQualified =
    let (Wrapper x) = Wrapper 42
    in  x

caseQualified =
    case Just 42 of
        Maybe.Just x -> x
        Nothing -> 0

caseScope : String
caseScope =
    case "Not this one!" of
        string ->
            case "Hi" of
                string -> string

tests : Test
tests =
    let primes =
            suite "Primes"
            [ test "case" <| assertEqual 42 (casePrime (Just 42))
            , test "pattern" <| assertEqual 42 patternPrime
            ]
        qualifiedPatterns =
            suite "Qualified Patterns"
            [ test "let" <| assertEqual 42 letQualified
            , test "case" <| assertEqual 42 caseQualified
            ]
        scope =
            suite "Scoping"
            [ test "case" <| assertEqual "Hi" caseScope ]
    in
        suite "CodeGen"
            [ primes
            , qualifiedPatterns
            , scope
            ]
