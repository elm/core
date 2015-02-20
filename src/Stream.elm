module Stream
    ( Stream
    , map
    , merge, mergeMany
    , fold
    , filter, filterMap
    , never
    , timestamp
    ) where

{-| Streams of events. Many interactions with the world can be formulated as
streams of events: mouse clicks, responses from servers, key presses, etc.

This library provides the basic building blocks for routing these streams of
events to your application logic.
-}

import List
import Mailbox (Mailbox)
import Maybe (Maybe(..))
import Signal
import Signal (Varying)
import Native.Signal
import Time (Time)


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


fromVarying : Varying a -> (a, Stream a)
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

