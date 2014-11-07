# Next Version

### Improvements

  * Add `Maybe.andThen`
  * Add `Result` library

### Breaking Changes

#### Syntax

  * Keyword `type` becomes `type alias`
  * Keyword `data` becomes `type`

#### Libraries

  * Revamp `Random` library, no longer signal-based
  * Remove `Either` in favor of `Result` or custom union types
  * Replace `List.zip` and `List.zipWith` with `List.mapN`
  * Rename `String.show` to `String.toString`

  * Rename `Signal.liftN` to `Signal.mapN`
  * Revamp `Input` concept as `Signal.Channel`
  * Rename `Signal.merges` to `Signal.mergeMany`
  * Remove `Signal.count`
  * Remove `Signal.countIf`


