module Signal
    ( Signal, Stream, Varying
    , Channel, Message
    , channel, send, subscribe
    ) where

{-| The library for general signal manipulation. Includes mapping, merging,
filters, past-dependence, and helpers for handling inputs from the UI.

Some useful functions for working with time (e.g. setting FPS) and combining
signals and time (e.g.  delaying updates, getting timestamps) can be found in
the [`Time`](Time) library.

# Channels
@docs channel, send, subscribe

-}

import Native.Signal
import List
import Basics (fst, snd, not, (|>))
import Debug


type Signal a = Signal


type alias Stream a = Signal a


type alias Varying a = Signal a



---- INPUTS ----

type Channel a = Channel -- Signal a

type Message = Message -- () -> ()


{-| Create a signal channel that you can `send` messages to. To receive these
messages, `subscribe` to the channel and turn it into a normal signal. The
primary use case is receiving updates from UI elements such as buttons and
text fields. The argument is a default value for the custom signal.

Note: This is an inherently impure function, so `(channel ())`
and `(channel ())` produce two different channels.
-}
channel : a -> Channel a
channel =
    Native.Signal.input


{-| Create a `Message` that can be sent to a `Channel` with a handler like
`Html.onclick` or `Html.onblur`. This doesn't actually send the message; it just
creates the message to be sent.

    import Html

    type Update = NoOp | Add Int | Remove Int

    updates : Channel Update
    updates = channel NoOp

    addButton : Html.Html
    addButton =
        Html.button
            [ onclick (send updates (Add 1)) ]
            [ Html.text "Add 1" ]
-}
send : Channel a -> a -> Message
send =
    Native.Signal.send


{-| Receive all the messages sent to a `Channel` as a `Signal`. The following
example shows how you would set up a system that uses a `Channel`.

    -- initialState : Model
    -- type Update = NoOp | ...
    -- step : Update -> Model -> Model
    -- view : Channel Update -> Model -> Element

    updates : Channel Update
    updates = channel NoOp

    main : Signal Element
    main =
      map
        (view updates)
        (foldp step initialState (subscribe updates))

The `updates` channel appears twice in `main` because it serves as a bridge
between your view and your signals. In the view you `send` to it, and in signal
world you `subscribe` to it.
-}
subscribe : Channel a -> Signal a
subscribe =
    Native.Signal.subscribe
