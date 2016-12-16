module Test.CodeGen exposing (tests)

import Basics exposing (..)
import Test exposing (..)
import Expect
import Maybe
import Maybe exposing (..)


type Wrapper a
    = Wrapper a


casePrime m_ =
    case m_ of
        Just x ->
            x

        Nothing ->
            0


patternPrime =
    case Just 42 of
        Just x_ ->
            x_

        Nothing ->
            0


letQualified =
    let
        (Wrapper x) =
            Wrapper 42
    in
        x


caseQualified =
    case Just 42 of
        Maybe.Just x ->
            x

        Nothing ->
            0


caseScope : String
caseScope =
    case "Not this one!" of
        string ->
            case "Hi" of
                string ->
                    string


tests : Test
tests =
    let
        primes =
            describe "Primes"
                [ test "case" <| \() -> Expect.equal 42 (casePrime (Just 42))
                , test "pattern" <| \() -> Expect.equal 42 patternPrime
                ]

        qualifiedPatterns =
            describe "Qualified Patterns"
                [ test "let" <| \() -> Expect.equal 42 letQualified
                , test "case" <| \() -> Expect.equal 42 caseQualified
                ]

        scope =
            describe "Scoping"
                [ test "case" <| \() -> Expect.equal "Hi" caseScope ]
    in
        describe "CodeGen"
            [ primes
            , qualifiedPatterns
            , scope
            ]
