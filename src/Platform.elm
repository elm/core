module Platform exposing
  ( Program, program, programWithFlags
  , Task, ProcessId
  , Router, sendToApp, sendToSelf
  )

{-|

# Programs
@docs Program, program, programWithFlags

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
import Platform.Cmd exposing (Cmd)
import Platform.Sub exposing (Sub)



-- PROGRAMS


{-| A `Program` describes how to manage your Elm app.

You can create [headless][] programs with the [`program`](#program) and
[`programWithFlags`](#programWithFlags) functions. Similar functions exist in
[`Html`][html] that let you specify a view.

[headless]: https://en.wikipedia.org/wiki/Headless_software
[html]: http://package.elm-lang.org/packages/elm-lang/html/latest/Html

Honestly, it is totally normal if this seems crazy at first. The best way to
understand is to work through [guide.elm-lang.org](http://guide.elm-lang.org/).
It makes way more sense in context!
-}
type Program flags model msg = Program


{-| Create a [headless][] program. This is great if you want to use Elm as the
&ldquo;brain&rdquo; for something else. You can still communicate with JS via
ports and manage your model, you just do not have to specify a `view`.

[headless]: https://en.wikipedia.org/wiki/Headless_software

Initializing a headless program from JavaScript looks like this:

```javascript
var app = Elm.MyThing.worker();
```
-}
program
  : { init : (model, Cmd msg)
    , update : msg -> model -> (model, Cmd msg)
    , subscriptions : model -> Sub msg
    }
  -> Program Never model msg
program =
  Native.Platform.program


{-| Same as [`program`](#program), but you can provide flags. Initializing a
headless program (with flags) from JavaScript looks like this:

```javascript
var app = Elm.MyThing.worker({ user: 'Tom', token: 1234 });
```

Whatever argument you provide to `worker` will get converted to an Elm value,
allowing you to configure your Elm program however you want from JavaScript!
-}
programWithFlags
  : { init : flags -> (model, Cmd msg)
    , update : msg -> model -> (model, Cmd msg)
    , subscriptions : model -> Sub msg
    }
  -> Program flags model msg
programWithFlags =
  Native.Platform.programWithFlags



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
