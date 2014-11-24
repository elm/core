# 0.14

### Syntax

  * Keyword `type` becomes `type alias`
  * Keyword `data` becomes `type`
  * Remove special list syntax in types, so `[a]` becomes `List a`


### Make JSON parsing easy

  * Added `JavaScript.ToElm`, `JavaScript.FromElm`, and `Json` libraries


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

        (?) : Maybe a -> a -> a
        oneOf : List (Maybe a) -> Maybe a
        map : (a -> b) -> Maybe a -> Maybe b
        andThen : Maybe a -> (a -> Maybe b) -> Maybe b

  * Remove `Maybe.maybe` so `maybe 0 sqrt Nothing` becomes `map sqrt Nothing ? 0`

  * Add `Result` library for proper error handling. This is for cases when
    you want a computation to succeed, but if there is a mistake, it should
    produce a nice error message.

  * Remove `Either` in favor of `Result` or custom union types

  * Revamp functions that result in a `Maybe`.

      - Remove `Dict.getOrElse` and `Dict.getOrFail` in favor of `Dict.get key dict ? 0`
      - Remove `Array.getOrElse` and `Array.getOrFail` in favor of `Array.get index array ? 0`
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
