module Debug exposing
  ( toString
  , log
  , todo
  , logTime
  )

{-| This module can be useful while _developing_ an application. It is not
available for use in packages or production.

# Debugging
@docs toString, log, todo, logTime
-}


import Elm.Kernel.Debug
import String exposing (String)


{-| Turn any kind of value into a string.

    toString 42                == "42"
    toString [1,2]             == "[1,2]"
    toString ('a', "cat", 13)  == "('a', \"cat\", 13)"
    toString "he said, \"hi\"" == "\"he said, \\\"hi\\\"\""

Notice that with strings, this is not the `identity` function. It escapes
characters so if you say `Html.text (toString "he said, \"hi\"")` it will
show `"he said, \"hi\""` rather than `he said, "hi"`. This makes it nice
for viewing Elm data structures.

**Note:** This is not available with `elm make --optimize` which gets rid of
a bunch of runtime metadata. For example, it shortens record field names, and
we need that info to `toString` the value! As a consequence, packages cannot
use `toString` because they may be used in `--optimize` mode.
-}
toString : a -> String
toString =
  Elm.Kernel.Debug.toString


{-| Log a tagged value on the developer console, and then return the value.

    1 + log "number" 1        -- equals 2, logs "number: 1"
    length (log "start" [])   -- equals 0, logs "start: []"

It is often possible to sprinkle this around to see if values are what you
expect. It is kind of old-school to do it this way, but it works!

**Note:** This is not available with `elm make --optimize` because (1) it
relies on `toString` which has the same restriction and (2) it is not a pure
function and would therefore have unpredictable behavior when paired with
compiler optimizations that move code around.

**Note:** If you want to create a terminal application that prints stuff out,
use ports for now. That will give you full access to reading and writing in the
terminal. We may have a package in Elm for this someday, but browser
applications are the primary focus of platform development for now.
-}
log : String -> a -> a
log =
  Elm.Kernel.Debug.log


{-| This is a placeholder for code that you will write later.

For example, if you are working with a large union type and have partially
completed a case expression, it may make sense to do this:

    type Entity = Ship | Fish | Captain | Seagull

    drawEntity entity =
      case entity of
        Ship ->
          ...

        Fish ->
          ...

        _ ->
          Debug.todo "handle Captain and Seagull"

The Elm compiler recognizes each `Debug.todo` so if you run into it, you get
an **uncatchable runtime exception** that includes the module name and line
number.

**Note:** This is not available with `elm make --optimize` or packages. The
idea is that a `todo` can be useful during development, but uncatchable runtime
exceptions should not appear in the resulting applications.

**Note:** For the equivalent of try/catch error handling in Elm, use modules
like [`Maybe`](#Maybe) and [`Result`](#Result) which guarantee that no error
goes unhandled!
-}
todo : String -> a
todo =
  Elm.Kernel.Debug.todo


{-| Log the execution time of a function.

This will help you track down performance issues by logging the execution
time of any function to the console. Most browsers also displays the time in
their [performance debugging] tools.
The first argument is a label which will be displayed in the console. This helps
when tracking multiple functions at the same time.

This will call `fn` with `arg` and log the execution time in the console. The
return value will be whatever `fn` returns.

    logTime "name in console" fn arg

If a function takes more than one argument you need to apply all but the last
one, effectively creating a one argument function.

    logTime "render header" (renderHeader arg1 arg2) arg3

**Note:** This is not available with `elm make --optimize` or in packages. The
idea is that `logTime` can be useful during development, but you would't want
to clutter the console with this information in the resulting application.

[performance debugging]: https://developers.google.com/web/tools/chrome-devtools/console/track-executions
-}
logTime : String -> (a -> b) -> a -> b
logTime =
  Elm.Kernel.Debug.logTime

