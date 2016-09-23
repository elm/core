effect module Time where { subscription = MySub } exposing
  ( Time
  , now, every
  , millisecond, second, minute, hour
  , inMilliseconds, inSeconds, inMinutes, inHours
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
import List exposing ((::))
import Maybe exposing (Maybe(..))
import Native.Scheduler
import Native.Time
import Platform
import Platform.Sub exposing (Sub)
import Task exposing (Task)



-- TIMES


{-| Type alias to make it clearer when you are working with time values.
Using the `Time` helpers like `second` and `inSeconds` instead of raw numbers
is very highly recommended.
-}
type alias Time = Float


{-| Get the `Time` at the moment when this task is run.
-}
now : Task x Time
now =
  Native.Time.now


{-| Subscribe to the current time. First you provide an interval describing how
frequently you want updates. Second, you give a tagger that turns a time into a
message for your `update` function. So if you want to hear about the current
time every second, you would say something like this:

    type Msg = Tick Time | ...

    subscriptions model =
      every second Tick

Check out the [Elm Architecture Tutorial][arch] for more info on how
subscriptions work.

[arch]: https://github.com/evancz/elm-architecture-tutorial/

**Note:** this function is not for animation! You need to use something based
on `requestAnimationFrame` to get smooth animations. This is based on
`setInterval` which is better for recurring tasks like “check on something
every 30 seconds”.
-}
every : Time -> (Time -> msg) -> Sub msg
every interval tagger =
  subscription (Every interval tagger)



-- UNITS


{-| Units of time, making it easier to specify things like a half-second
`(500 * millisecond)` without remembering Elm&rsquo;s underlying units of time.
-}
millisecond : Time
millisecond =
  1


{-|-}
second : Time
second =
  1000 * millisecond


{-|-}
minute : Time
minute =
  60 * second


{-|-}
hour : Time
hour =
  60 * minute


{-|-}
inMilliseconds : Time -> Float
inMilliseconds t =
  t


{-|-}
inSeconds : Time -> Float
inSeconds t =
  t / second


{-|-}
inMinutes : Time -> Float
inMinutes t =
  t / minute


{-|-}
inHours : Time -> Float
inHours t =
  t / hour



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
      , Native.Scheduler.kill id
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
          Native.Scheduler.spawn (setInterval interval (Platform.sendToSelf router interval))

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
  Native.Time.setInterval_
