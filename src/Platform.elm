module Platform exposing
  ( Program
  , Task, ProcessId
  , Router, sendToApp, sendToSelf
  )

{-|

# Programs
@docs Program

# Platform Internals

## Tasks and Processes
@docs Task, ProcessId

## Effect Manager Helpers

An extremely tiny portion of library authors should ever write effect managers.
Fundamentally, Elm needs maybe 10 of them total. I get that people are smart,
curious, etc. but that is not a substitute for a legitimate reason to make an
effect manager. Do you have an *organic need* this fills? Or are you just
curious? Public discussions of your explorations should be framed accordingly.

@docs Router, sendToApp, sendToSelf
-}

import Basics exposing (Never)
import Native.Platform
import Native.Scheduler



-- PROGRAMS


{-| Every Elm project will define `main` to be some sort of `Program`. A
`Program` value captures all the details needed to manage your application,
including how to initialize things, how to respond to events, etc.

The type of a `Program` includes a `flags` type variable which describes the
data we need to start a program. So say our program needs to be given a `userID`
and `token` to get started:

    MyApp.main : Program { userID : String, token : Int }

So when we initialize this program in JavaScript, we can give the necessary flags
really easily!

```javascript
Elm.MyApp.fullscreen({
    userID: "Tom",
    token: 42
});
```
-}
type Program flags = Program



-- TASKS and PROCESSES

{-| Head over to the documentation for the [`Task`](Task) module for more
information on this. It is only defined here because it is a platform
primitive.
-}
type Task err ok = Task


{-| Head over to the documentation for the [`Process`](Process) module for
information on this. It is only defined here because it is a platform
primitive.
-}
type ProcessId = ProcessId



-- EFFECT MANAGER INTERNALS


{-| An effect manager has access to a “router” that routes messages between
the main app and your individual effect manager.
-}
type Router appMsg selfMsg =
  Router


{-| Send the router a message for the main loop of your app. This message will
be handled by the overall `update` function, just like events from `Html`.
-}
sendToApp : Router msg a -> msg -> Task x ()
sendToApp =
  Native.Platform.sendToApp


{-| Send the router a message for your effect manager. This message will
be routed to the `onSelfMsg` function, where you can update the state of your
effect manager as necessary.

As an example, the effect manager for web sockets
-}
sendToSelf : Router a msg -> msg -> Task x ()
sendToSelf =
  Native.Platform.sendToSelf


hack =
  Native.Scheduler.succeed
