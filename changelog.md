# Next Version

### Improvements

  * Add `Maybe.andThen`
  * Add `Result` library

### Breaking Changes

  * Revamp `Random` library, no longer signal-based

  * Rename `Signal.lift` to `Signal.map`
  * Rename `Signal.lift2` to `Signal.zip`
  * Rename `Signal.liftN` to `Signal.zipN`
  * Rename `Signal.merges` to `Signal.mergeMany`
  * Revamp `Input` concept, move it to the Signal library
  * Remove `Signal.count`
  * Remove `Signal.countIf`

  * Remove `List.zip`
  * Rename `List.zipWith` to `List.zip`

