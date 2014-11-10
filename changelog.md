# Next Version

### Syntax

  * Keyword `type` becomes `type alias`
  * Keyword `data` becomes `type`


### Libraries

  * Add `Maybe.andThen`

  * Add `Result` library

  * Remove `Either` in favor of `Result` or custom union types

  * Add the following functions to `Text`:
      
        empty : Text
        append : Text -> Text -> Text
        concat : [Text] -> Text
        join : Text -> [Text] -> Text

  * Revamp `Random` library, no longer signal-based

  * Make the following changes in `List`:
      - Replace `List.zip` and `List.zipWith` with `List.mapN`
      - Replace `(++)` with `append`
      - Remove `join`

  * Rename `String.show` to `String.toString`

  * Make the following changes to `Signal`:
      - Rename `Signal.liftN` to `Signal.mapN`
      - Revamp `Input` concept as `Signal.Channel`
      - Rename `Signal.merges` to `Signal.mergeMany`
      - Remove `Signal.count`
      - Remove `Signal.countIf`


