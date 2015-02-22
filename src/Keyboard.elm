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
@docs arrows, wasd, Directions, toXY

# Specific Keys
The following signals are `True` when the particular key is pressed and `False`
otherwise.

@docs enter, space, ctrl, shift, alt, meta

# General Keypresses
@docs isDown, keysDown, presses

-}

import Basics exposing (always, (-))
import Set
import Stream exposing (Stream)
import Native.Keyboard
import Varying exposing (Varying)


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



model : Varying Model
model =
  Stream.fold update empty rawEvents


rawEvents : Stream Event
rawEvents =
  Stream.mergeMany
    [ Stream.map Up Native.Keyboard.ups
    , Stream.map Down Native.Keyboard.downs
    , Stream.map (always Blur) Native.Keyboard.blurs
    ]


-- PUBLIC API

type alias Directions =
    { up : KeyCode
    , down : KeyCode
    , left : KeyCode
    , right : KeyCode
    }


toXY : Directions -> Set.Set KeyCode -> { x : Int, y : Int }
toXY {up,down,left,right} keyCodes =
  let is keyCode =
        if Set.member keyCode keyCodes
          then 1
          else 0
  in
      { x = is up - is down
      , y = is right - is left
      }


{-| A signal of records indicating which arrow keys are pressed.

  * `{ x = 0, y = 0 }` when pressing no arrows.
  * `{ x =-1, y = 0 }` when pressing the left arrow.
  * `{ x = 1, y = 1 }` when pressing the up and right arrows.
  * `{ x = 0, y =-1 }` when pressing the down, left, and right arrows.
-}
arrows : Varying { x:Int, y:Int }
arrows =
  Varying.map (toXY { up = 38, down = 40, left = 37, right = 39 }) keysDown


{-| Just like the arrows signal, but this uses keys w, a, s, and d,
which are common controls for many computer games.
-}
wasd : Varying { x:Int, y:Int }
wasd =
  Varying.map (toXY { up = 87, down = 83, left = 65, right = 68 }) keysDown


{-| Whether an arbitrary key is pressed. -}
isDown : KeyCode -> Varying Bool
isDown keyCode =
  Varying.map (Set.member keyCode) keysDown


alt : Varying Bool
alt =
  Varying.map .alt model


ctrl : Varying Bool
ctrl =
  isDown 17


{-| The meta key is the Windows key on Windows and the Command key on Mac.
-}
meta : Varying Bool
meta =
  Varying.map .meta model


shift : Varying Bool
shift =
  isDown 16


space : Varying Bool
space =
  isDown 32


enter : Varying Bool
enter =
  isDown 13


{-| Set of keys that are currently down. -}
keysDown : Varying (Set.Set KeyCode)
keysDown =
  Varying.map .keyCodes model


{-| The latest key that has been pressed. -}
presses : Stream KeyCode
presses =
  Native.Keyboard.presses

