# 0.15

### Add Promises / Improve HTTP support

This release includes the `Promise` module which provides a general purpose
way to model effects. Long term, the `Promise` API will allow us to describe
*any* low-level browser API in a safe way.

The biggest result right now is that the new `Http` module is much more
flexible and easy to use. It has been moved out of the core libraries into
`evancz/elm-http`.

The `Promise` module motivates many of the subsequent changes.


### Signal becomes Stream/Varying

The `Signal` module has been split into two separate concepts:

  * `Stream` is a stream of discrete events. It has no initial value or
    current value. It is nice for events like clicks or key presses.
  * `Varying` is a value that varies. It is always defined, changing at
    discrete moments. This is nice for things like `Mouse.position` or the
    current state of your application.

There is nothing fundamentally new here, the underlying implementation is
pretty much unchanged. The big difference is that the `Signal` API has been
split accross the `Stream` and `Varying` modules, hopefully clarifying things.

### Channel becomes Mailbox

As [architecture guidelines][arch] have developed, the concept of a `Channel`
got a bit messy. It grew to include `LocalChannel` and had [more fundamental
issues](https://github.com/elm-lang/elm-compiler/issues/889). This motivates
the `Mailbox` abstraction.

[arch]: https://github.com/evancz/elm-architecture-tutorial

```elm
type alias Mailbox a =
    { address : Address a
    , stream : Stream a
    }

send : Address a -> a -> Promise x ()

forward : (a -> b) -> Address b -> Address a
```

A `Mailbox` has an `address` you can send values to, and a `stream` that
receives all of those values. The `forward` function lets you create
forwarding addresses that just send the message along, adding some extra
information. This is very helpful for writing more modular code.


# 0.14

### Syntax

  * Keyword `type` becomes `type alias`
  * Keyword `data` becomes `type`
  * Remove special list syntax in types, so `[a]` becomes `List a`


### Reduce Default Imports

The set of default imports has been reduced to the following:

```haskell
import Basics (..)
import Maybe ( Maybe( Just, Nothing ) )
import Result ( Result( Ok, Err ) )
import List ( List )
import Signal ( Signal )
```

### Make JSON parsing easy

  * Added `Json.Decode` and `Json.Encode` libraries


### Use more natural names

  * Rename `String.show` to `String.toString`

  * Replace `List.zip` with `List.map2 (,)`
  * Replace `List.zipWith f` with `List.map2 f`

  * Rename `Signal.liftN` to `Signal.mapN`
  * Rename `Signal.merges` to `Signal.mergeMany`


### Simplify Signal Library

  * Revamp `Input` concept as `Signal.Channel`
  * Remove `Signal.count`
  * Remove `Signal.countIf`


### Randomness Done Right

  * No longer signal-based
  * Use a `Generator` to create random values



### Revamp Maybes and Error Handling

  * Add the following functions to `Maybe`

        withDefault : a -> Maybe a -> a
        oneOf : List (Maybe a) -> Maybe a
        map : (a -> b) -> Maybe a -> Maybe b
        andThen : Maybe a -> (a -> Maybe b) -> Maybe b

  * Remove `Maybe.maybe` so `maybe 0 sqrt Nothing` becomes `withDefault 0 (map sqrt Nothing)`

  * Remove `Maybe.isJust` and `Maybe.isNothing` in favor of pattern matching

  * Add `Result` library for proper error handling. This is for cases when
    you want a computation to succeed, but if there is a mistake, it should
    produce a nice error message.

  * Remove `Either` in favor of `Result` or custom union types

  * Revamp functions that result in a `Maybe`.

      - Remove `Dict.getOrElse` and `Dict.getOrFail` in favor of `withDefault 0 (Dict.get key dict)`
      - Remove `Array.getOrElse` and `Array.getOrFail` in favor of `withDefault 0 (Array.get index array)`
      - Change `String.toInt : String -> Maybe Int` to `String.toInt : String -> Result String Int`
      - Change `String.toFloat : String -> Maybe Float` to `String.toFloat : String -> Result String Float`


### Make appending more logical

  * Add the following functions to `Text`:
      
        empty : Text
        append : Text -> Text -> Text
        concat : [Text] -> Text
        join : Text -> [Text] -> Text

  * Make the following changes in `List`:
      - Replace `(++)` with `append`
      - Remove `join`

### Miscellaneous

  * Rename `Text.toText` to `Text.fromString`