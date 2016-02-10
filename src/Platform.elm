module Platform
  ( Program, program, programWithFlags
  , Cmd, Sub
  )
  where
{-|

# Programs

@docs Program, program, programWithFlags


# Effects

Elm is built around guarantees like:

  * Adding new code will *never* break old code.
  * If you give a function the same inputs, it will *always* give you the same output.

These guarantees are the core of why programming, testing, and reuse are so
nice in Elm. All of this is made possible by Elm’s **managed effects**.

The essense of managed effects is to treat all effects as data. So instead of
just talking to a server whenever you want, you use commands and subscriptions.

@docs Cmd, Sub
-}


import Native.Platform



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
[exponential backoff]() strategy, *Elm* does this all for you behind the
scenes!

Every `Sub` specifies (1) which effects you need access to and (2) the type of
messages that will come back into your application.

**Note:** Do not worry if this seems confusing at first! As with every Elm user
ever, subscriptions will make more sense as you work through [the Elm Architecture
Tutorial]() and see how they fit into a real application!
-}
type Sub effects msg = Sub


{-| The ultimate goal of Elm is to create a great programs!

So a `Program` captures all the details needed to manage your application. When
you create a `Program` the type will also have some important information.

First, **`flags`** represents the type of data we need to start a program. So
say our program needs to be given a `name` and `age` to get started:

    type alias Flags = { name : String, age : Int }

    main : Program Flags [Task]

So when we initialize this program in JavaScript, we can give the necessary flags
really easily!

```javascript
Elm.fullscreen(Elm.MyApp, { name: "Tom", age: 42 });
```

Second, **`effects`** is a list of all the different effects that are needed by
your program. This will be things like `Task` and `WebSocket` and `Animation`.
Elm uses this list to know exactly which effects need to be managed as the
program runs. As a beginner, you can totally ignore these details and get tons
of stuff done, so do not get freaked out! It will become clear with use, so
the important thing is to dive in to things like [the Elm Architecture
Tutorial]() and try things out in practice!
-}
type Program flags effects = Program


{-|
-}
program
  : { init : (model, Cmd effects msg)
    , update : msg -> model -> (model, Cmd effects msg)
    , view : model -> Html msg
    , subscriptions : model -> Sub effects msg
    }
  -> Program flags effects
program =
  Native.Platform.program


{-|
-}
programWithFlags
  : { init : flags -> (model, Cmd effects msg)
    , update : msg -> model -> (model, Cmd effects msg)
    , view : model -> Html msg
    , subscriptions : model -> Sub effects msg
    }
  -> Program flags effects
programWithFlags =
  Native.Platform.program

