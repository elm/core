effect module Time where { subscription = MySub } exposing
  ( Posix
  , now
  , epoch
  , posixToMillis
  , millisToPosix
  , toIso8601
  , fromIso8601
  , Zone
  , utc
  , Date
  , year
  , month
  , day
  , weekday
  , hour
  , minute
  , second
  , millis
  , diff
  , travel
  , Unit(..)
  , every
  , Month(..)
  , Weekday(..)
  )

{-| Library for working with time.

# Time
@docs Time, now, every

# Units
@docs millisecond, second, minute, hour,
  inMilliseconds, inSeconds, inMinutes, inHours

-}


import Basics exposing (..)
import Dict
import Elm.Kernel.Scheduler
import Elm.Kernel.Time
import List exposing ((::))
import Maybe exposing (Maybe(..))
import Platform
import Platform.Sub exposing (Sub)
import Task exposing (Task)



-- POSIX


{-| Type alias to make it clearer when you are working with time values.
Using the `Time` helpers like `second` and `inSeconds` instead of raw numbers
is very highly recommended.
-}
type Posix = Posix Int


{-| Get the POSIX time at the moment when this task is run.
-}
now : Task x Posix
now =
  Elm.Kernel.Time.now ()


epoch : Posix
epoch =
  Posix 0


posixToMillis : Posix -> Int
posixToMillis (Posix millis) =
  millis


millisToPosix : Int -> Maybe Posix
millisToPosix millis =
  if millis < 0 then
    Nothing
  else
    Just (Posix millis)


toIso8601 : Posix -> String
toIso8601 posix =
  Debug.crash "TODO toIso8601"


fromIso8601 : String -> Maybe Posix
fromIso8601 string =
  Debug.crash "TODO fromIso8601"



-- TIME ZONES


type Zone =
  Zone String (List Era)


type alias Era =
  { start : Int
  , offset : Int
  , abbr : String
  }


utc : Zone
utc =
  Zone "etc_utc" []


-- here : Task x Zone


toZone : String -> Maybe Zone
toZone string =
  case String.split "|" string of
    [name, rawAbbrs, rawOffsets, rawIndexes, rawDiffs] ->
      let
        abbrs = String.split " " rawAbbrs
        offsets = String.split " " rawOffsets
        indexes = String.toList rawIndexes
        diffs = String.split " " rawDiffs
      in
      toZoneHelp name (toAbbrOffsetMap abbrs offsets) indexes diffs 0 []

    _ ->
      Nothing


toAbbrOffsetMap : List String -> List String -> List (String, Int) -> List (String, Int)
toAbbrOffsetMap abbrs offsets revAbbrOffsetMap =
  case (abbrs, offsets) of
    (abbr :: otherAbbrs, offset :: otherOffsets) ->
      let
        intOffset =
          String.foldr addChar60 0 offset
      in
      if intOffset < 0 then
        Nothing
      else
        toAbbrOffsetMap otherAbbrs otherOffsets ((abbr, intOffset) :: revAbbrOffsetMap)

    ([], []) ->
      Just (List.reverse revAbbrOffsetMap)

    _ ->
      Nothing


addChar60 : Char -> Int -> Int
addChar60 char answer =
  let code = Char.toCode char in
  if answer < 0 then
    answer

  else if 0x30 <= code && code <= 0x39 then
    60 * answer + code - 0x30

  else if 0x41 <= code && code <= 0x5A then
    60 * answer + 10 + code - 0x41

  else if 0x61 <= code && code <= 0x7A then
    60 * answer + 36 + code - 0x61

  else
    -1


toZoneHelp : String -> List (String, Int) -> List Char -> List String -> Int -> List Era -> Maybe Zone
toZoneHelp name abbrOffsetMap index60s diff60s runningOffset eras =
  case (index60s, diff60s) of
    (index60 : futureIndex60s, diff60 : futureDiff60s) ->
      case lookupChar60 index60 abbrOffsetMap of
        Nothing ->
          Nothing

        Just (abbr, offset) ->
          let diff = String.foldr addChar60 0 diff60 in
          if diff < 0 then
            Nothing
          else
            let start = runningOffset + diff in
            toZoneHelp name abbrOffsetMap futureIndex60s futureDiff60s start <|
              Era start offset abbr :: eras

    ([], []) ->
      Just (Zone name eras)

    _ ->
      Nothing



-- DATES


type alias Date =
  { time : Posix
  , zone : Zone
  }


year : Date -> Int
year date =
  (toCivil (toAdjustedMinutes date)).year


month : Date -> Month
month date =
  unsafeIntToMonth (toCivil (toAdjustedMinutes date)).month


day : Date -> Int
day date =
  (toCivil (toAdjustedMinutes date)).day


weekday : Date -> Weekday
weekday date =
  case modBy 7 (toAdjustedMinutes date // (60 * 24)) of
    0 -> Thu
    1 -> Fri
    2 -> Sun
    3 -> Sat
    4 -> Mon
    5 -> Tue
    _ -> Wed


hour : Date -> Int
hour date =
  modBy 24 (toAdjustedMinutes date // 60)


minute : Date -> Int
minute date =
  modBy 60 (toAdjustedMinutes date)


second : Date -> Int
second date =
  modBy 60 (posixToMillis date.time // 1000)


millis : Date -> Int
millis date =
  modBy 1000 (posixToMillis date.time)



-- DATE HELPERS


toAdjustedMinutes : Date -> Int
toAdjustedMinutes date =
  let (Zone _ eras) = date.zone in
  toAdjustedMinutesHelp (posixToMillis date.time // 60000) eras


toAdjustedMinutesHelp : Int -> List Era -> Int
toAdjustedMinutesHelp posixMinutes eras =
  case eras of
    [] ->
      posixMinutes

    era :: olderEras ->
      if era.start < posixMinutes then
        posixMinutes + era.offset
      else
        toAdjustedMinutesHelp posixMinutes olderEras


toCivil : Int -> { year : Int, month : Int, day : Int }
toCivil minutes =
  let
    rawDay    = (minutes // (60 * 24)) + 719468
    era       = (if rawDay >= 0 then rawDay else rawDay - 146096) // 146097
    dayOfEra  = rawDay - era * 146097 -- [0, 146096]
    yearOfEra = (dayOfEra - dayOfEra // 1460 + dayOfEra // 36524 - dayOfEra // 146096) // 365 -- [0, 399]
    year      = yearOfEra + era * 400
    dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra // 4 - yearOfEra // 100) -- [0, 365]
    mp        = (5 * dayOfYear + 2) // 153 -- [0, 11]
    month     = mp + (if mp < 10 then 3 else -9) -- [1, 12]
  in
  { year = year + (if month <= 2 then 1 else 0)
  , month = month
  , day = dayOfYear - (153 * mp + 2) // 5 + 1 -- [1, 31]
  }



-- MOVING AROUND STUFF


-- diff : Unit -> Date -> Date -> Int
travel : Unit -> Int -> Date -> Date

type Unit = Years | Months | Days | Hours | Minutes | Seconds | Millis



{-|

**Note:** this function is not for animation!
-}
every : Unit -> Int -> (Posix -> msg) -> Sub msg
every interval tagger =
  subscription (Every interval tagger)



-- WEEKDAYS AND MONTHS


{-| Represents a `Weekday` so that you can convert it to a `String` or `Int`
however you please. For example, if you need the Japanese representation, you
can say:

    toJapaneseWeekday : Weekday -> String
    toJapaneseWeekday weekday =
      case weekday of
        Mon -> "月"
        Tue -> "火"
        Wed -> "水"
        Thu -> "木"
        Fri -> "金"
        Sat -> "土"
        Sun -> "日"
-}
type Weekday = Mon | Tue | Wed | Thu | Fri | Sat | Sun


{-| Represents a `Month` so that you can convert it to a `String` or `Int`
however you please. For example, if you need the Danish representation, you
can say:

    toDanishMonth : Month -> String
    toDanishMonth month =
      case month of
        Jan -> "januar"
        Feb -> "februar"
        Mar -> "marts"
        Apr -> "april"
        May -> "maj"
        Jun -> "juni"
        Jul -> "juli"
        Aug -> "august"
        Sep -> "september"
        Oct -> "oktober"
        Nov -> "november"
        Dec -> "december"
-}
type Month = Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec


unsafeIntToMonth : Int -> Month
unsafeIntToMonth int =
  case int of
    1  -> Jan
    2  -> Feb
    3  -> Mar
    4  -> Apr
    5  -> May
    6  -> Jun
    7  -> Jul
    8  -> Aug
    9  -> Sep
    10 -> Oct
    11 -> Nov
    _  -> Dec



-- SUBSCRIPTIONS


type MySub msg =
  Every Time (Time -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap f (Every interval tagger) =
  Every interval (f << tagger)



-- EFFECT MANAGER


type alias State msg =
  { taggers : Taggers msg
  , processes : Processes
  }


type alias Processes =
  Dict.Dict Time Platform.ProcessId


type alias Taggers msg =
  Dict.Dict Time (List (Time -> msg))


init : Task Never (State msg)
init =
  Task.succeed (State Dict.empty Dict.empty)


onEffects : Platform.Router msg Time -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router subs {processes} =
  let
    newTaggers =
      List.foldl addMySub Dict.empty subs

    leftStep interval taggers (spawnList, existingDict, killTask) =
      (interval :: spawnList, existingDict, killTask)

    bothStep interval taggers id (spawnList, existingDict, killTask) =
      (spawnList, Dict.insert interval id existingDict, killTask)

    rightStep _ id (spawnList, existingDict, killTask) =
      ( spawnList
      , existingDict
      , Elm.Kernel.Scheduler.kill id
          |> Task.andThen (\_ -> killTask)
      )

    (spawnList, existingDict, killTask) =
      Dict.merge
        leftStep
        bothStep
        rightStep
        newTaggers
        processes
        ([], Dict.empty, Task.succeed ())
  in
    killTask
      |> Task.andThen (\_ -> spawnHelp router spawnList existingDict)
      |> Task.andThen (\newProcesses -> Task.succeed (State newTaggers newProcesses))


addMySub : MySub msg -> Taggers msg -> Taggers msg
addMySub (Every interval tagger) state =
  case Dict.get interval state of
    Nothing ->
      Dict.insert interval [tagger] state

    Just taggers ->
      Dict.insert interval (tagger :: taggers) state


spawnHelp : Platform.Router msg Time -> List Time -> Processes -> Task.Task x Processes
spawnHelp router intervals processes =
  case intervals of
    [] ->
      Task.succeed processes

    interval :: rest ->
      let
        spawnTimer =
          Elm.Kernel.Scheduler.spawn (setInterval interval (Platform.sendToSelf router interval))

        spawnRest id =
          spawnHelp router rest (Dict.insert interval id processes)
      in
        spawnTimer
          |> Task.andThen spawnRest


onSelfMsg : Platform.Router msg Time -> Time -> State msg -> Task Never (State msg)
onSelfMsg router interval state =
  case Dict.get interval state.taggers of
    Nothing ->
      Task.succeed state

    Just taggers ->
      let
        tellTaggers time =
          Task.sequence (List.map (\tagger -> Platform.sendToApp router (tagger time)) taggers)
      in
        now
          |> Task.andThen tellTaggers
          |> Task.andThen (\_ -> Task.succeed state)


setInterval : Time -> Task Never () -> Task x Never
setInterval =
  Elm.Kernel.Time.setInterval
