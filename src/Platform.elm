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

### init

The first argument, `init` is a [Tuple](Tuple) that lets you specify how your program should start.
Its first value is the initial state of your program's model.
The second value is an initial command. Often that command is [Cmd.none](Platform-Cmd#none).

### update

The second argument, `update` is a function that takes these two arguments:

1. A message from the outside world that has the information your code will act upon.
Usually this is a [Msg type](https://www.elm-tutorial.org/en/02-elm-arch/03-messages.html)
that you specify, which takes a record type matching the data coming from an incoming port.
Unpack that data with `case` ... `of`.

2. The current state of your program's model.

The `update` function must return a [Tuple](Tuple) containing the modified form
of your program's model, and a command.

It is common to generate that command by passing data to an outbound port.
Then the data type this command holds is determined by Elm, and probably
will __not__ match any type you have defined in your code.

### subscriptions

The third argument, `subscriptions` is a function that accepts your program's model, and returns a
[Sub](Platform-Sub).
As explained in [the effects section of the Elm language guide](https://guide.elm-lang.org/architecture/effects/),
it _"declares any event sources you need to subscribe to given the current model."_
Your model might not be used in your definition of the `subscriptions` function.
Instead you will probably only call an input port function and pass it a message type you have defined
which accepts a certain data structure from outside of Elm.

It's possible that the `subscriptions` function _could_ return differing [Sub](Platform-Sub)s based on
the state of your model. To specify multiple subscriptions, use [Sub.batch](Platform-Sub#batch).

A code example may help. Here we have program that greets visitors by name, keeps a head count,
and shuts down its subscription after greeting more than three visitors:

```elm
port module Greet exposing (..)

import Json.Decode

port greet : String -> Cmd a

port inputName : ( String -> msg ) -> Sub msg

type Msg = Name String

type alias Model = { visitors : Int }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Name name ->
      let
        newModel =
          model.visitors + 1 |> Model
        greeting =
          "Hi " ++ name ++ ", you're visitor " ++ toString newModel.visitors
      in
        ( newModel, greet greeting )

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.visitors > 3 then
    Sub.none
  else
    inputName Name

main : Program Never Model Msg
main =
  Platform.program {
    init = ( Model 0, Cmd.none ),
    update = update,
    subscriptions = subscriptions
  }
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
