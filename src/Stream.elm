module Stream
    ( Stream
    , toSignal, fromSignal
    , map
    , merge, mergeMany
    , fold
    , filter, filterMap
    , sample
    , never
    , timestamp
    ) where

{-| Streams of events. Many interactions with the world can be formulated as
a stream of discrete events: mouse clicks, responses from servers, key presses,
etc.

This library provides the basic building blocks for routing these streams of
events to your application logic.

# Mapping
@docs map

# Merging
@docs merge, mergeMany

# Folding
@docs fold

# Filtering
@docs filterMap, filter, sample

# Primitive Streams
@docs never, timestamp

# Conversions
@docs toSignal, fromSignal
-}

import Basics exposing ((|>))
import List
import Maybe exposing (Maybe(..))
import Native.Signal
import SignalTypes exposing (Signal)
import Time exposing (Time)


type alias Stream a =
    SignalTypes.Stream a


{-| Apply a function to events as they come in. This lets you transform
streams.

    type Action = MouseClick | TimeDelta Float

    actions : Stream Action
    actions =
        map (always MouseClick) Mouse.clicks
-}
map : (a -> b) -> Stream a -> Stream b
map =
  Native.Signal.streamMap


{-| Convert a stream of values into a signal that updates whenever an event
comes in on the stream.

    url : Signal String
    url =
      toSignal "waiting.gif" imageStream

    constant : a -> Signal a
    constant value =
      toSignal value Stream.never
-}
toSignal : a -> Stream a -> Signal a
toSignal =
  Native.Signal.streamToSignal


{-| Get a stream that triggers whenever the signal is *updated*. Note
that an update may result in the same value as before, so the resulting
`Stream` can have the same value twice in a row.

    moves : Stream (Int,Int)
    moves =
      fromSignal Mouse.position
-}
fromSignal : Signal a -> Stream a
fromSignal =
  Native.Signal.signalToStream


{-| Merge two streams into one. This function is extremely useful for bringing
together lots of different streams to feed into a `fold`.

    type Action = MouseClick | TimeDelta Float

    actions : Stream Action
    actions =
        merge
            (map (always MouseClick) Mouse.clicks)
            (map TimeDelta (fps 40))

If an event comes from either of the incoming streams, it flows out the
outgoing stream. If an event comes on both streams at the same time, the left
event wins (i.e., the right event is discarded).
-}
merge : Stream a -> Stream a -> Stream a
merge left right =
  Native.Signal.genericMerge (\x _ -> x) left right


{-| Merge many streams into one. This is useful when you are merging more than
two streams. When multiple events come in at the same time, the left-most
event wins, just like with `merge`.

    type Action = MouseMove (Int,Int) | TimeDelta Float | Click

    actions : Stream Action
    actions =
        mergeMany
            [ map MouseMove Mouse.position
            , map TimeDelta (fps 40)
            , map (always Click) Mouse.clicks
            ]
-}
mergeMany : List (Stream a) -> Stream a
mergeMany streams =
  List.foldr merge never streams


{-| Create a past-dependent value. Each update from the incoming stream will
be used to step the state forward. The outgoing signal represents the current
state.

    clickCount : Signal Int
    clickCount =
        fold (\click total -> total + 1) 0 Mouse.clicks

    timeSoFar : Stream Time
    timeSoFar =
        fold (+) 0 (fps 40)

So `clickCount` updates on each mouse click, incrementing by one. `timeSoFar`
is the time the program has been running, updated 40 times a second.
-}
fold : (a -> b -> b) -> b -> Stream a -> Signal b
fold =
  Native.Signal.fold


{-| Filter out some events. The given function decides whether we should
keep an update. The following example only keeps even numbers.

    numbers : Stream Int

    isEven : Int -> Bool

    evens : Stream Int
    evens =
        filter isEven numbers
-}
filter : (a -> Bool) -> Stream a -> Stream a
filter isOk stream =
  filterMap (\v -> if isOk v then Just v else Nothing) stream


{-| Filter out some events. If the incoming event is mapped to a `Nothing` it
is dropped. If it is mapped to `Just` a value, we keep the value.

    numbers : Stream Int
    numbers =
        filterMap (\raw -> Result.toMaybe (String.toInt raw)) userInput

    userInput : Stream String
-}
filterMap : (a -> Maybe b) -> Stream a -> Stream b
filterMap =
  Native.Signal.filterMap


{-| Useful for augmenting a stream with information from a signal.
For example, if you are operating on a time delta but want to take the current
keyboard state into account.

    inputs : Stream ({ x:Int, y:Int }, Time)
    inputs =
        sample (,) Keyboard.arrows (fps 60)

Now we get events exactly with the `(fps 60)` stream, but they are augmented
with which arrows are pressed at the moment.
-}
sample : (a -> b -> c) -> Signal a -> Stream b -> Stream c
sample f signal events =
  let (initialValue, signalUpdates) =
          (Native.Signal.initialValue signal, fromSignal signal)

      sampleEvents =
          Native.Signal.genericMerge (\(value,_) (_,event) -> (value,event))
            (map (\value -> (Just value, Nothing)) signalUpdates)
            (map (\event -> (Nothing, Just event)) events)
  in
      fold sampleUpdate { value = initialValue, event = Nothing } sampleEvents
        |> fromSignal
        |> filterMap (\state -> Maybe.map (f state.value) state.event)


type alias SampleState a b =
    { value : a
    , event : Maybe b
    }


sampleUpdate : (Maybe a, Maybe b) -> SampleState a b -> SampleState a b
sampleUpdate (newState, event) state =
    { value = Maybe.withDefault state.value newState
    , event = event
    }


{-| A stream that never gets an update. This is useful when defining functions
like `mergeMany` which needs to be defined even when no streams are given.

    mergeMany : List (Stream a) -> Stream a
    mergeMany streams =
        List.foldr merge never streams
-}
never : Stream a
never =
  Native.Signal.never


{-| Add a timestamp to any stream. Timestamps increase monotonically. When you
create `(timestamp Mouse.x)`, an initial timestamp is produced. The timestamp
updates whenever `Mouse.x` updates.

Timestamp updates are tied to individual events, so
`(timestamp Mouse.x)` and `(timestamp Mouse.y)` will always have the same
timestamp because they rely on the same underlying event (`Mouse.position`).
-}
timestamp : Stream a -> Stream (Time, a)
timestamp =
  Native.Signal.timestamp
