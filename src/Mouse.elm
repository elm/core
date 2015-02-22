module Mouse
    ( position, x, y
    , isDown, clicks
    ) where

{-| Library for working with mouse input.

# Position
@docs position, x, y

# Button Status
@docs isDown, clicks

-}

import Basics exposing (fst, snd)
import Stream exposing (Stream)
import Native.Mouse


{-| The current mouse position. -}
position : Varying (Int,Int)
position =
  Native.Mouse.position


{-| The current x-coordinate of the mouse. -}
x : Varying Int
x =
  Varying.map fst position


{-| The current y-coordinate of the mouse. -}
y : Varying Int
y =
  Varying.map snd position


{-| The current state of the left mouse-button.
True when the button is down, and false otherwise. -}
isDown : Varying Bool
isDown =
  Native.Mouse.isDown


{-| Always equal to unit. Event triggers on every mouse click. -}
clicks : Stream ()
clicks =
  Native.Mouse.clicks

