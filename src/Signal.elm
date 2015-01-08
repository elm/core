module Signal where
{-| The library for general signal manipulation. Includes mapping, merging,
filters, past-dependence, and helpers for handling inputs from the UI.

Some useful functions for working with time (e.g. setting FPS) and combining
signals and time (e.g.  delaying updates, getting timestamps) can be found in
the [`Time`](Time) library.

# Merging
@docs merge, mergeMany

# Mapping
@docs map, map2, map3, map4, map5

# Fancy Mapping
@docs (<~), (~)

# Past-Dependence
@docs foldp

# Filters
@docs keepIf, dropIf, keepWhen, dropWhen, dropRepeats, sampleOn

# Channels
@docs channel, send, subscribe

# Constants
@docs constant

-}

import Native.Signal
import List
import Basics (fst, snd, not)


type Signal a = Signal


{-| Create a constant signal that never changes. -}
constant : a -> Signal a
constant =
    Native.Signal.constant


{-| Apply a function to the current value of a signal.

    mouseIsUp : Signal Bool
    mouseIsUp =
        map not Mouse.isDown

    main : Signal Element
    main =
        map toElement Mouse.position
-}
map : (a -> result) -> Signal a -> Signal result
map =
    Native.Signal.map


{-| Apply a function to the current value of two signals. The function is
reevaluated whenever *either* signal changes. In the following example, we
figure out the `aspectRatio` of the window by combining the current width and
height.

    ratio : Int -> Int -> Float
    ratio width height =
        toFloat width / toFloat height

    aspectRatio : Signal Float
    aspectRatio =
        map2 ratio Window.width Window.height
-}
map2 : (a -> b -> result) -> Signal a -> Signal b -> Signal result
map2 =
    Native.Signal.map2


map3 : (a -> b -> c -> result) -> Signal a -> Signal b -> Signal c -> Signal result
map3 =
    Native.Signal.map3


map4 : (a -> b -> c -> d -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal result
map4 =
    Native.Signal.map4


map5 : (a -> b -> c -> d -> e -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal result
map5 =
    Native.Signal.map5



{-| Create a past-dependent signal. Each update from the incoming signals will
be used to step the state forward. The outgoing signal represents the current
state.

    clickCount : Signal Int
    clickCount =
        foldp (\click total -> total + 1) 0 Mouse.clicks

    timeSoFar : Signal Time
    timeSoFar =
        foldp (+) 0 (fps 40)

So `clickCount` updates on each mouse click, incrementing by one. `timeSoFar`
is the time the program has been running, updated 40 times a second.
-}
foldp : (a -> state -> state) -> state -> Signal a -> Signal state
foldp =
    Native.Signal.foldp


{-| Merge two signals into one. This function is extremely useful for bringing
together lots of different signals to feed into a `foldp`.

    type Update = MouseMove (Int,Int) | TimeDelta Float

    updates : Signal Update
    updates =
        merge
            (map MouseMove Mouse.position)
            (map TimeDelta (fps 40))

If an update comes from either of the incoming signals, it updates the outgoing
signal. If an update comes on both signals at the same time, the left update
wins (i.e., the right update is discarded).
-}
merge : Signal a -> Signal a -> Signal a
merge =
    Native.Signal.merge


{-| Merge many signals into one. This is useful when you are merging more than
two signals. When multiple updates come in at the same time, the left-most
update wins, just like with `merge`.

    type Update = MouseMove (Int,Int) | TimeDelta Float | Click

    updates : Signal Update
    updates =
        mergeMany
            [ map MouseMove Mouse.position
            , map TimeDelta (fps 40)
            , map (always Click) Mouse.clicks
            ]
-}
mergeMany : List (Signal a) -> Signal a
mergeMany signals =
    List.foldr1 merge signals


{-| Filter out some updates. The given function decides whether we should
keep an update. If no updates ever flow through, we use the default value
provided. The following example only keeps even numbers and has an initial
value of zero.

    numbers : Signal Int

    isEven : Int -> Bool

    evens : Signal Int
    evens =
        keepIf isEven 0 numbers
-}
keepIf : (a -> Bool) -> a -> Signal a -> Signal a
keepIf =
    Native.Signal.keepIf


{-| Filter out some updates. The given function decides whether we should
drop an update. If we drop all updates, we use the default value provided.
The following example drops all even numbers and has an initial value of
one.

    numbers : Signal Int

    isEven : Int -> Bool

    odds : Signal Int
    odds =
        dropIf isEven 1 numbers
-}
dropIf : (a -> Bool) -> a -> Signal a -> Signal a
dropIf =
    Native.Signal.dropIf


{-| Keep updates when the first signal is true. You provide a default value
just in case that signal is *never* true and no updates make it through. For
example, here is how you would capture mouse drags.

    dragPosition : Signal (Int,Int)
    dragPosition =
        keepWhen Mouse.isDown (0,0) Mouse.position
-}
keepWhen : Signal Bool -> a -> Signal a -> Signal a
keepWhen bs def sig = 
    snd <~ (keepIf fst (False, def) ((,) <~ (sampleOn sig bs) ~ sig))


{-| Drop events when the first signal is true. You provide a default value
just in case that signal is *always* true and we drop all updates.
-}
dropWhen : Signal Bool -> a -> Signal a -> Signal a
dropWhen bs = keepWhen (not <~ bs)


{-| Drop updates that repeat the current value of the signal.

    numbers : Signal Int

    noDups : Signal Int
    noDups =
        dropRepeats numbers

    --  numbers => 0 0 3 3 5 5 5 4 ...
    --  noDups  => 0   3   5     4 ...

The signal should not be a signal of functions, or a record that contains a
function (you'll get a runtime error since functions cannot be equated).
-}
dropRepeats : Signal a -> Signal a
dropRepeats =
    Native.Signal.dropRepeats


{-| Sample from the second input every time an event occurs on the first input.
For example, `(sampleOn Mouse.clicks (Time.every Time.second))` will give the
approximate time of the latest click. -}
sampleOn : Signal a -> Signal b -> Signal b
sampleOn =
    Native.Signal.sampleOn


{-| An alias for `map`. A prettier way to apply a function to the current value
of a signal.
-}
(<~) : (a -> b) -> Signal a -> Signal b
f <~ s =
    Native.Signal.map f s


{-| Intended to be paired with the `(<~)` operator, this makes it possible for
many signals to flow into a function. Think of it as a fancy alias for `mapN`.
For example, the following declarations are equivalent:

    main : Signal Element
    main =
      scene <~ Window.dimensions ~ Mouse.position

    main : Signal Element
    main =
      map2 scene Window.dimensions Mouse.position

You can use this pattern for as many signals as you want by using `(~)` a bunch
of times, so you can go higher than `map5` if you need to.
-}
(~) : Signal (a -> b) -> Signal a -> Signal b
sf ~ s =
    Native.Signal.map2 (\f x -> f x) sf s

infixl 4 <~
infixl 4 ~


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
