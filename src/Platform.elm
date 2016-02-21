module Platform
  ( Program
  , Process
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


# Processes

@docs Process

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



-- PROCESSES


{-| Head over to the documentation for the [`Process`](Process) module for
information on how this works. It is only defined here because it needs to be
a platform primitive for both the `Task` and `Process` modules to use it.
-}
type Process exit msgs = Process

