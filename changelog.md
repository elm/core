# Next Version

### Improvements

  * Add `Maybe.andThen`
  * Add `Result` library

### Breaking Changes

  * Revamp `Random` library, no longer signal-based
  * Remove `Either` in favor of `Result` or custom union types

  * Rename `Signal.liftN` to `Signal.mapN`
  * Rename `Signal.merges` to `Signal.mergeMany`
  * Revamp `Input` concept as `Signal.Channel`
  * Remove `Signal.count`
  * Remove `Signal.countIf`

  * Replace `List.zip` and `List.zipWith` with `List.mapN`

  * Rename `String.show` to `String.toString`

