module Keyboard
    ( KeyCode
    , arrows, wasd
    , enter, space, ctrl, shift, alt, meta
    , isDown, keysDown, presses
    ) where

{-| Library for working with keyboard input.

# Representing Keys
@docs KeyCode

# Directions
@docs arrows, wasd

# Specific Keys
The following signals are `True` when the particular key is pressed and `False`
otherwise.

@docs enter, space, ctrl, shift, alt, meta

# General Keypresses
@docs isDown, keysDown, presses

-}

import Basics exposing (always, (-))
import Set
import Native.Keyboard
import Signal exposing (Signal)


{-| Type alias to make it clearer what integers are supposed to represent
in this library. Use `Char.toCode` and `Char.fromCode` to convert key codes
to characters. Use the uppercase character with `toCode`.
-}
type alias KeyCode = Int


-- MANAGE RAW STREAMS

type alias Model =
    { alt : Bool
    , meta : Bool
    , keyCodes : Set.Set KeyCode
    }


empty : Model
empty =
    { alt = False
    , meta = False
    , keyCodes = Set.empty
    }


type Event = Up EventInfo | Down EventInfo | Blur

type alias EventInfo =
    { alt : Bool
    , meta : Bool
    , keyCode : KeyCode
    }


update : Event -> Model -> Model
update event model =
  case event of
    Down info ->
        { alt = info.alt
        , meta = info.meta
        , keyCodes = Set.insert info.keyCode model.keyCodes
        }

    Up info ->
        { alt = info.alt
        , meta = info.meta
        , keyCodes = Set.remove info.keyCode model.keyCodes
        }

    Blur ->
        empty



model : Signal Model
model =
  Signal.foldp update empty rawEvents


rawEvents : Signal Event
rawEvents =
  Signal.mergeMany
    [ Signal.map Up Native.Keyboard.ups
    , Signal.map Down Native.Keyboard.downs
    , Signal.map (always Blur) Native.Keyboard.blurs
    ]


-- PUBLIC API

{-| Key codes for different layouts. You can set it up to be WASD, arrow keys, etc.

    arrowKeys = { up = 38, down = 40, left = 37, right = 39 }
    wasdKeys = { up = 87, down = 83, left = 65, right = 68 }
-}
type alias Directions =
    { up : KeyCode
    , down : KeyCode
    , left : KeyCode
    , right : KeyCode
    }


{-| Extract an x and y value representing directions from a set of key codes
that are currently pressed. For example, you can use this to define `wasd`
like this:

    wasd : Signal { x : Int, y : Int }
    wasd =
        Signal.map (toXY { up = 87, down = 83, left = 65, right = 68 }) keysDown
-}
toXY : Directions -> Set.Set KeyCode -> { x : Int, y : Int }
toXY {up,down,left,right} keyCodes =
  let is keyCode =
        if Set.member keyCode keyCodes
          then 1
          else 0
  in
      { x = is right - is left
      , y = is up - is down
      }


{-| A signal of records indicating which arrow keys are pressed.

  * `{ x = 0, y = 0 }` when pressing no arrows.
  * `{ x =-1, y = 0 }` when pressing the left arrow.
  * `{ x = 1, y = 1 }` when pressing the up and right arrows.
  * `{ x = 0, y =-1 }` when pressing the down, left, and right arrows.
-}
arrows : Signal { x:Int, y:Int }
arrows =
  Signal.map (toXY { up = 38, down = 40, left = 37, right = 39 }) keysDown


{-| Just like the arrows signal, but this uses keys w, a, s, and d,
which are common controls for many computer games.
-}
wasd : Signal { x:Int, y:Int }
wasd =
  Signal.map (toXY { up = 87, down = 83, left = 65, right = 68 }) keysDown


{-| Whether an arbitrary key is pressed. -}
isDown : KeyCode -> Signal Bool
isDown keyCode =
  Signal.map (Set.member keyCode) keysDown


alt : Signal Bool
alt =
  Signal.map .alt model


ctrl : Signal Bool
ctrl =
  isDown 17


{-| The meta key is the Windows key on Windows and the Command key on Mac.
-}
meta : Signal Bool
meta =
  Signal.map .meta model


shift : Signal Bool
shift =
  isDown 16


space : Signal Bool
space =
  isDown 32


enter : Signal Bool
enter =
  isDown 13


{-| Set of keys that are currently down. -}
keysDown : Signal (Set.Set KeyCode)
keysDown =
  Signal.map .keyCodes model


{-| The latest key that has been pressed. -}
presses : Signal KeyCode
presses =
  Signal.map .keyCode Native.Keyboard.presses

