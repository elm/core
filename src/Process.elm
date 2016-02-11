module Process
  ( Process
  , spawn
  , send
  , kill
  )
  where
{-|

# Processes
@docs Process, spawn, send, kill

-}

import Basics exposing (Never)
import Native.Scheduler
import Platform
import Task exposing (Task)


{-| A light-weight process that runs concurrently. You can use `Task.spawn` to
get a bunch of different tasks running in different processes. The Elm runtime
will interleave their progress. So if a task is taking too long, we will pause
it at an `andThen` and switch over to other stuff.

**Note:** We make a distinction between *concurrency* which means interleaving
different sequences and *parallelism* which means running different
sequences at the exact same time. For example, a
[time-sharing system](https://en.wikipedia.org/wiki/Time-sharing) is definitely
concurrent, but not necessarily parallel. So even though JS runs within a
single OS-level thread, Elm can still run things concurrently.
-}
type alias Process exit msgs =
  Platform.Process exit msgs


{-| Run a task in its own light-weight process. In the following example,
`task1` and `task2` will be interleaved. If `task1` makes a long HTTP request
or is just taking a long time, we can hop over to `task2` and do some work
there.

    spawn task1 `Task.andThen` \_ -> spawn task2

**Note:** This creates a relatively restricted kind of `Process` because it
cannot receive any messages. More flexibility for user-defined processes will
come in a later release!
-}
spawn : Task x a -> Task y (Process x Never)
spawn =
  Native.Scheduler.spawn


{-| Sometimes you `spawn` a process, but later decide it would be a waste to
have it keep running and doing stuff. The `kill` function will force a process
to bail on whatever task it is running. So if there is an HTTP request in
flight, it will also abort the request.
-}
kill : Process exit msg -> Task x ()
kill =
  Native.Scheduler.kill


{-| Send a message to a process's message queue.

**Note:** Right now users can only `spawn` processes that never receive
messages. If you are defining an `effect module` (which for 99% of readers
should not be) you will need to use this function.
-}
send : Process exit msg -> msg -> Task x ()
send =
  Native.Scheduler.send


