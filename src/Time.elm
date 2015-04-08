module Time
    ( Time, millisecond, second, minute, hour
    , inMilliseconds, inSeconds, inMinutes, inHours
    , fps, fpsWhen, every
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
import Native.Time
import SignalTypes exposing (Stream)
import Signal exposing (Signal)


{-| Type alias to make it clearer when you are working with time values.
Using the `Time` constants instead of raw numbers is very highly recommended.
-}
type alias Time = Float


{-| Units of time, making it easier to specify things like a half-second
`(500 * milliseconds)` without remembering Elm&rsquo;s underlying units of time.
-}
millisecond : Time
millisecond =
  1


second : Time
second =
  1000 * millisecond


minute : Time
minute =
  60 * second


hour : Time
hour =
  60 * minute


inMilliseconds : Time -> Float
inMilliseconds t =
  t


inSeconds : Time -> Float
inSeconds t =
  t / second


inMinutes : Time -> Float
inMinutes t =
  t / minute


inHours : Time -> Float
inHours t =
  t / hour


{-| Takes desired number of frames per second (FPS). The resulting signal
gives a sequence of time deltas as quickly as possible until it reaches
the desired FPS. A time delta is the time between the last frame and the
current frame.

Note: Calling `fps 30` twice gives two independently running timers.
-}
fps : number -> Stream Time
fps targetFrames =
  fpsWhen targetFrames (Signal.constant True)


{-| Same as the `fps` function, but you can turn it on and off. Allows you
to do brief animations based on user input without major inefficiencies.
Summing the time deltas in the output stream will give the amount of time
that the input signal has been turned on.
-}
fpsWhen : number -> Signal Bool -> Stream Time
fpsWhen =
  Native.Time.fpsWhen


{-| Takes a time interval `t`. The resulting signal is the current time, updated
every `t`.

Note: Calling `every 100` twice gives two independently running timers.
-}
every : Time -> Signal Time
every =
  Native.Time.every
