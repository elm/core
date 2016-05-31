module Platform.Cmd exposing
  ( Cmd
  , map
  , batch
  , none
  , (!)
  )

{-|

# Effects

Elm has **managed effects**, meaning that things like HTTP requests or writing
to disk are all treated as *data* in Elm. When this data is given to the Elm
runtime system, it can do some “query optimization” before actually performing
the effect. Perhaps unexpectedly, this managed effects idea is the heart of why
Elm is so nice for testing, reuse, reproducibility, etc.

There are two kinds of managed effects you will use in your programs: commands
and subscriptions.

@docs Cmd, map, batch, none, (!)

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
Tutorial](http://guide.elm-lang.org/architecture/index.html) and see how they
fit into a real application!
-}
type Cmd msg = Cmd


{-|-}
map : (a -> msg) -> Cmd a -> Cmd msg
map =
  Native.Platform.map


{-|-}
batch : List (Cmd msg) -> Cmd msg
batch =
  Native.Platform.batch


{-|-}
none : Cmd msg
none =
  batch []


{-|-}
(!) : model -> List (Cmd msg) -> (model, Cmd msg)
(!) model commands =
  (model, batch commands)

