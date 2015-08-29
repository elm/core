module Time
    ( Time, millisecond, second, minute, hour
    , inMilliseconds, inSeconds, inMinutes, inHours
    , fps, fpsWhen, every
    , timestamp, delay, since
    ) where

{-| Library for working with time.

# Units
@docs Time, millisecond, second, minute, hour,
      inMilliseconds, inSeconds, inMinutes, inHours

# Tickers
@docs fps, fpsWhen, every

# Timing
@docs timestamp, delay, since
-}

import Basics exposing (..)
import Native.Signal
import Native.Time
import Signal exposing (Signal)


{-| Type alias to make it clearer when you are working with time values.
Using the `Time` constants instead of raw numbers is very highly recommended.
-}
type alias Time = Float


{-| Units of time, making it easier to specify things like a half-second
`(500 * millisecond)` without remembering Elm&rsquo;s underlying units of time.
-}
millisecond : Time
millisecond =
  1


{-|-}
second : Time
second =
  1000 * millisecond


{-|-}
minute : Time
minute =
  60 * second


{-|-}
hour : Time
hour =
  60 * minute


{-|-}
inMilliseconds : Time -> Float
inMilliseconds t =
  t


{-|-}
inSeconds : Time -> Float
inSeconds t =
  t / second


{-|-}
inMinutes : Time -> Float
inMinutes t =
  t / minute


{-|-}
inHours : Time -> Float
inHours t =
  t / hour


{-| Takes desired number of frames per second (FPS). The resulting signal
gives a sequence of time deltas as quickly as possible until it reaches
the desired FPS. A time delta is the time between the last frame and the
current frame.

Note: Calling `fps 30` twice gives two independently running timers.
-}
fps : number -> Signal Time
fps targetFrames =
  fpsWhen targetFrames (Signal.constant True)


{-| Same as the `fps` function, but you can turn it on and off. Allows you
to do brief animations based on user input without major inefficiencies.
The first time delta after a pause is always zero, no matter how long
the pause was. This way summing the deltas will actually give the amount
of time that the output signal has been running.
-}
fpsWhen : number -> Signal Bool -> Signal Time
fpsWhen =
  Native.Time.fpsWhen


{-| Takes a time interval `t`. The resulting signal is the current time, updated
every `t`.

Note: Calling `every 100` twice gives two independently running timers.
-}
every : Time -> Signal Time
every =
  Native.Time.every


{-| Add a timestamp to any signal. Timestamps increase monotonically. When you
create `(timestamp Mouse.x)`, an initial timestamp is produced. The timestamp
updates whenever `Mouse.x` updates.

Timestamp updates are tied to individual events, so `(timestamp Mouse.x)` and
`(timestamp Mouse.y)` will always have the same timestamp because they rely on
the same underlying event (`Mouse.position`).
-}
timestamp : Signal a -> Signal (Time, a)
timestamp =
  Native.Signal.timestamp


{-| Delay a signal by a certain amount of time. So `(delay second Mouse.clicks)`
will update one second later than any mouse click.

Note: Even calling `delay` with the same number on the same signal twice
gives two independently firing signals.
-}
delay : Time -> Signal a -> Signal a
delay =
  Native.Signal.delay


{-| Takes a time `t` and any signal. The resulting boolean signal is true for
time `t` after every event on the input signal. So ``(second `since`
Mouse.clicks)`` would result in a signal that is true for one second after
each mouse click and false otherwise.
-}
since : Time -> Signal a -> Signal Bool
since time signal =
  let
    start =
      Signal.map (always 1) signal

    stop =
      Signal.map (always -1) (delay time signal)

    delaydiff =
      Signal.foldp (+) 0 (Signal.merge start stop)
  in
      Signal.map ((/=) 0) delaydiff
