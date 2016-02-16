module Platform
  ( Program
  , Process, program, programWithFlags
  , Cmd, Sub
  )
  where
{-|

# Programs

@docs Program


# Effects

Elm has **managed effects**, meaning that things like HTTP requests or writing
to disk are all treated as *data* in Elm. When this data is given to the Elm
runtime system, it can do some “query optimization” before actually performing
the effect. Perhaps unexpectedly, this managed effects idea is the heart of why
Elm is so nice for testing, reuse, reproducability, etc.

There are two kinds of managed effects you will use in your programs: commands
and subscriptions.

@docs Cmd, Sub


# Details for Platform Implementers

@docs Process, program, programWithFlags

-}


import Basics exposing (Never)
import Native.Platform



-- EFFECTS


{-| A command is a way of telling Elm, “Hey, I want you to do this thing!”
So if you want to send an HTTP request, you would need to command Elm to do it.
Or if you wanted to ask for geolocation, you would need to command Elm to go
get it.

Every `Cmd` specifies (1) which effects you need access to and (2) the type of
messages that will come back into your application.

**Note:** Do not worry if this seems confusing at first! As with every Elm user
ever, commands will make more sense as you work through [the Elm Architecture
Tutorial]() and see how they fit into a real application!
-}
type Cmd effects msg = Cmd


{-| A subscription is a way of telling Elm, “Hey, let me know if anything
interesting happens over there!” So if you want listen for messages on a web
socket, you would tell Elm to create a subscription. If you want to get clock
ticks, you would tell Elm to subscribe to that. The cool thing here is that
this means *Elm* manages all the details of subscriptions instead of *you*.
So if a web socket goes down, *you* do not need to manually reconnect with an
exponential backoff strategy, *Elm* does this all for you behind the scenes!

Every `Sub` specifies (1) which effects you need access to and (2) the type of
messages that will come back into your application.

**Note:** Do not worry if this seems confusing at first! As with every Elm user
ever, subscriptions will make more sense as you work through [the Elm Architecture
Tutorial]() and see how they fit into a real application!
-}
type Sub effects msg = Sub



-- PROGRAMS


{-| Every Elm project will define `main` to be some sort of `Program`. A
`Program` value captures all the details needed to manage your application,
including how to initialize things, how to respond to events, etc.

The type of a `Program` includes `flags` and `effects` which Elm uses to help
get everything started.

The **`flags`** type describes teh data we need to start a program. So say our
program needs to be given a `name` and `age` to get started:

    main : Program { name : String, age : Int } [Task]

So when we initialize this program in JavaScript, we can give the necessary flags
really easily!

```javascript
Elm.fullscreen(Elm.MyApp, { name: "Tom", age: 42 });
```

The **`effects`** type is a list of all the different effects that are needed
by your program. This will be things like `Task` and `WebSocket` and
`Animation`. Elm uses this list to know exactly which effects need to be
managed as the program runs. As a beginner, you can totally ignore these
details and get tons of stuff done, so do not get freaked out! It will become
clear with use, so the important thing is to dive in to things like [the Elm
Architecture Tutorial]() and try things out in practice!
-}
type Program flags effects = Program



-- DETAILS FOR PLATFORM IMPLEMENTERS


type Process exit msgs = Process


{-| **You should not use this directly.** This function is needed by the folks
on the core Elm team to implement things like HTML and SVG renderers.
-}
program
  : { init : (model, Cmd effects msg)
    , update : msg -> model -> (model, Cmd effects msg)
    , subscriptions : model -> Sub effects msg
    , view : model -> view
    , renderer : Renderer view msg
    }
  -> Program flags effects
program =
  Native.Platform.program


{-| **You should not use this directly.** This function is needed by the folks
on the core Elm team to implement things like HTML and SVG renderers.
-}
programWithFlags
  : { init : flags -> (model, Cmd effects msg)
    , update : msg -> model -> (model, Cmd effects msg)
    , subscriptions : model -> Sub effects msg
    , view : model -> view
    , renderer : Renderer view msg
    }
  -> Program flags effects
programWithFlags =
  Native.Platform.program


type Renderer view msg = Renderer


dummyRenderer : Renderer () msg
dummyRenderer =
  Native.Platform.dummyRenderer

