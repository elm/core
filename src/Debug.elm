module Debug exposing
  ( toString
  , log
  , crash
  )

{-| This library is for investigating bugs or performance problems. It should
*not* be used in production code.

# Debugging
@docs toString, log, crash
-}

import Elm.Kernel.Debug


{-| Turn any kind of value into a string.

    toString 42                == "42"
    toString [1,2]             == "[1,2]"
    toString ('a', "cat", 13)  == "('a', \"cat\", 13)"
    toString "he said, \"hi\"" == "\"he said, \\\"hi\\\"\""

Notice that with strings, this is not the `identity` function. It escapes
characters so if you say `Html.text (toString "he said, \"hi\"")` it will
show `"he said, \"hi\""` rather than `he said, "hi"`. This makes it nice
for viewing Elm data structures.
-}
toString : a -> String
toString =
  Elm.Kernel.Debug.toString


{-| Log a tagged value on the developer console, and then return the value.

    1 + log "number" 1        -- equals 2, logs "number: 1"
    length (log "start" [])   -- equals 0, logs "start: []"

Notice that `log` is not a pure function! It should *only* be used for
investigating bugs or performance problems.
-}
log : String -> a -> a
log =
  Elm.Kernel.Debug.log


{-| Crash the program with an error message. This is an uncatchable error,
intended for code that is soon-to-be-implemented. For example, if you are
working with a large union type and have partially completed a case expression, it may
make sense to do this:

    type Entity = Ship | Fish | Captain | Seagull

    drawEntity entity =
      case entity of
        Ship ->
          ...

        Fish ->
          ...

        _ ->
          Debug.crash "TODO"

The Elm compiler recognizes each `Debug.crash` and when you run into it at
runtime, the error will point to the corresponding module name and line number.
For `case` expressions that ends with a wildcard pattern and a crash, it will
also show the value that snuck through. In our example, that'd be `Captain` or
`Seagull`.

**Use this if** you want to do some testing while you are partway through
writing a function.

**Do not use this if** you want to do some typical try-catch exception handling.
Use the [`Maybe`](Maybe) or [`Result`](Result) libraries instead.
-}
crash : String -> a
crash =
  Elm.Kernel.Debug.crash

