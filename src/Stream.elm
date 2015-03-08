module Stream
    ( Stream
    , WritableStream
    , toVarying, fromVarying
    , map
    , merge, mergeMany
    , fold
    , filter, filterMap
    , sample
    , never
    , timestamp
    ) where

{-| Streams of events. Many interactions with the world can be formulated as
streams of events: mouse clicks, responses from servers, key presses, etc.

This library provides the basic building blocks for routing these streams of
events to your application logic.
-}

import Basics exposing ((|>), (>>), snd)
import List
import Mailbox exposing (Mailbox)
import Maybe exposing (Maybe(..))
import Native.Signal
import Signal exposing (Varying)
import Time exposing (Time)


type alias Stream a =
    Signal.Stream a


type alias WritableStream a =
    { mailbox : Mailbox a
    , stream : Stream a
    }


map : (a -> b) -> Stream a -> Stream b
map =
  Native.Signal.streamMap


toVarying : a -> Stream a -> Varying a
toVarying =
  Native.Signal.streamToVarying


fromVarying : Varying a -> Stream a
fromVarying =
  Native.Signal.varyingToStream


{-| Merge two streams into one. This function is extremely useful for bringing
together lots of different streams to feed into a `fold`.

    type Action = MouseMove (Int,Int) | TimeDelta Float

    actions : Stream Action
    actions =
        merge
            (map MouseMove Mouse.position)
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
be used to step the state forward. The outgoing varying represents the current
state.

    clickCount : Varying Int
    clickCount =
        fold (\click total -> total + 1) 0 Mouse.clicks

    timeSoFar : Stream Time
    timeSoFar =
        fold (+) 0 (fps 40)

So `clickCount` updates on each mouse click, incrementing by one. `timeSoFar`
is the time the program has been running, updated 40 times a second.
-}
fold : (a -> b -> b) -> b -> Stream a -> Varying b
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


filterMap : (a -> Maybe b) -> Stream a -> Stream b
filterMap =
  Native.Signal.filterMap


{-| Useful for augmenting a stream with information from a varying value.
For example, if you are operating on a time delta but want to take the current
keyboard state into account.

    sample (,) Keyboard.arrows (fps 60)

Now we get events exactly with the `(fps 60)` stream, but they are augmented
with which arrows are pressed at the moment.
-}
sample : (a -> b -> c) -> Varying a -> Stream b -> Stream c
sample f varying events =
  let (initialValue, varyingUpdates) =
          fromVarying varying

      sampleEvents =
          merge
            (map Sample events)
            (map Update varyingUpdates)
  in
      fold sampleUpdate { state = initialValue, trigger = Nothing } sampleEvents
        |> (fromVarying >> snd)
        |> filterMap (\state -> Maybe.map (f state.state) state.trigger)


type SampleEvent a b = Sample a | Update b


type alias SampleState a b =
    { state : b
    , trigger : Maybe a
    }


sampleUpdate : SampleEvent a b -> SampleState a b -> SampleState a b
sampleUpdate event state =
  case event of
    Sample a ->
        { state = state.state
        , trigger = Just a
        }

    Update b ->
        { state = b
        , trigger = Nothing
        }


never : Stream a
never =
  Native.Signal.never


{-| Add a timestamp to any signal. Timestamps increase monotonically. When you
create `(timestamp Mouse.x)`, an initial timestamp is produced. The timestamp
updates whenever `Mouse.x` updates.

Timestamp updates are tied to individual events, so
`(timestamp Mouse.x)` and `(timestamp Mouse.y)` will always have the same
timestamp because they rely on the same underlying event (`Mouse.position`).
-}
timestamp : Stream a -> Stream (Time, a)
timestamp =
  Native.Signal.timestamp

