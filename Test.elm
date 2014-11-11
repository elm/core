module Test where

import JavaScript (..)
import JavaScript as JS

import Text (asText)

port test : JS.Value


type alias Point = { x : Float, y : Float }

point =
  object2 Point ("x" := float) ("y" := float)

main =
    asText (JS.run point test)