module Test.Text (tests) where

import ElmTest.Assertion (..)
import ElmTest.Test (..)
import Basics (..)
import Text (..)
import Native.Test.Text


tests : Test
tests =
    suite "Text Tests"
        [ testFromString
        ]

toHtmlString : Text -> String
toHtmlString =
    Native.Test.Text.textToHtmlString

testFromString : Test
testFromString =
    let result = toHtmlString (fromString "Hello")
    in
        test "simple" <| assertEqual "Hello" result 
