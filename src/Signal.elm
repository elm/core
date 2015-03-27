module Signal
    ( Signal
    , fromStream, toStream, destructure
    , map, map2, map3, map4, map5
    , (<~), (~)
    , constant
    ) where

{-| A *signal* is a value that changes over time. For example, we can
think of the mouse position as a pair of numbers that is changing over time,
whenever the user moves the mouse.

    Mouse.position : Signal (Int,Int)

Another signal is the `Element` or `Html` we want to show on screen.

    main : Signal Html

As the `Html` changes, the user sees different things on screen automatically.

# Mapping
@docs map, map2, map3, map4, map5

# Fancy Mapping
@docs (<~), (~)

# Conversions
@docs toStream, fromStream, destructure

# Constant
@docs constant
-}

import Native.Signal
import SignalTypes exposing (Stream)


type alias Signal a =
    SignalTypes.Signal a


{-| Create a signal that never changes. This can be useful if you need
to pass a combination of signals and normal values to a function:

    map3 view Window.dimensions Mouse.position (constant initialModel)
-}
constant : a -> Signal a
constant =
  Native.Signal.constant


{-| Convert a stream of values into a signal that updates whenever an
event comes in on the stream.

    url : Signal String
    url =
      fromStream "waiting.gif" imageStream

    constant : a -> Signal a
    constant value =
      fromStream value Stream.never
-}
fromStream : a -> Stream a -> Signal a
fromStream =
  Native.Signal.streamToSignal


{-| Get a stream that triggers whenever the signal is *updated*. Note
that an update may result in the same value as before, so the resulting
`Stream` can have the same value twice in a row.

    moves : Stream (Int,Int)
    moves =
      toStream Mouse.position
-}
toStream : Signal a -> Stream a
toStream =
  Native.Signal.signalToStream


{-| Destructure a signal, resulting in the initial value and a stream
of all the updates. These things are conceptually equivalent.

This can be useful when you need the window dimensions to render your scene,
but you also need to update your model when a resize occurs.

    (initialSize, resizes) : ((Int,Int), Stream (Int,Int))
    (initialSize, resizes) =
      destructure Window.dimensions
-}
destructure : Signal a -> (a, Stream a)
destructure signal =
  (Native.Signal.initialValue signal, toStream signal)


{-| Apply a function to a signal.

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


{-| Apply a function to the current value of two signals. The function
is reevaluated whenever *either* signal changes. In the following example, we
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


{-| An alias for `map`. A prettier way to apply a function to the current value
of a signal.

    main : Signal Html
    main =
      view <~ model

    model : Signal Model

    view : Model -> Html
-}
(<~) : (a -> b) -> Signal a -> Signal b
(<~) =
  map


{-| Intended to be paired with the `(<~)` operator, this makes it possible for
many signals to flow into a function. Think of it as a fancy alias for
`mapN`. For example, the following declarations are equivalent:

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
(~) funcs args =
  map2 (\f v -> f v) funcs args


infixl 4 <~
infixl 4 ~


