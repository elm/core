module Debug exposing
  ( log
  , crash
  )

{-| This library is for investigating bugs or performance problems. It should
*not* be used in production code.

# Debugging
@docs log, crash
-}

import Native.Debug


{-| Log a tagged value on the developer console, and then return the value.

    1 + log "number" 1        -- equals 2, logs "number: 1"
    length (log "start" [])   -- equals 0, logs "start: []"

Notice that `log` is not a pure function! It should *only* be used for
investigating bugs or performance problems.
-}
log : String -> a -> a
log =
  Native.Debug.log


{-| Crash the program with an error message. This is an uncatchable error,
intended for code that is soon-to-be-implemented. For example, if you are
working with a large ADT and have partially completed a case expression, it may
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
  Native.Debug.crash

