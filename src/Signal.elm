module Signal
    ( Stream, Varying
    , Channel, Message
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


type Stream a = Stream


type Varying a = Varying



---- INPUTS ----

type Channel a = Channel -- Signal a

type Message = Message -- () -> ()


