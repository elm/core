module Test.Color exposing (tests)

import Basics exposing (..)
import Color
import List

import ElmTest exposing (..)

hslToTuple : Color.Color -> (Float, Float, Float)
hslToTuple color =
  let
    { hue, saturation, lightness } = Color.toHsl color
  in
    (hue, saturation, lightness)

tests : Test
tests = suite "Color"
  [ suite "rgbaToHsl"
    [ test "white" <| assertEqual (0,0,1) (hslToTuple Color.white)
    , test "black" <| assertEqual (0,0,0) (hslToTuple Color.black)
    , test "blue" <| assertEqual (degrees 240,1,0.5) (hslToTuple (Color.rgb 0 0 255))
    , test "red" <| assertEqual (0,1,0.5) (hslToTuple (Color.rgb 255 0 0))
    , test "green" <| assertEqual (degrees 120,1,0.5) (hslToTuple (Color.rgb 0 255 0))
    ]
  ]
