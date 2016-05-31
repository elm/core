effect module Task where { command = MyCmd } exposing
  ( Task
  , succeed, fail
  , map, map2, map3, map4, map5, andMap
  , sequence
  , andThen
  , onError, mapError
  , toMaybe, fromMaybe, toResult, fromResult
  , perform
  )

{-| Tasks make it easy to describe asynchronous operations that may fail, like
HTTP requests or writing to a database. For more information, see the [Elm
documentation on Tasks](http://guide.elm-lang.org/error_handling/task.html).

# Basics
@docs Task, succeed, fail

# Mapping
@docs map, map2, map3, map4, map5, andMap

# Chaining
@docs andThen, sequence

# Errors
@docs onError, mapError, toMaybe, fromMaybe, toResult, fromResult

# Commands
@docs perform

-}

import Basics exposing (Never)
import List exposing ((::))
import Maybe exposing (Maybe(Just,Nothing))
import Native.Scheduler
import Platform
import Platform.Cmd exposing (Cmd)
import Result exposing (Result(Ok,Err))



{-| Represents asynchronous effects that may fail. It is useful for stuff like
HTTP.

For example, maybe we have a task with the type (`Task String User`). This means
that when we perform the task, it will either fail with a `String` message or
succeed with a `User`. So this could represent a task that is asking a server
for a certain user.
-}
type alias Task err ok =
  Platform.Task err ok



-- BASICS


{-| A task that succeeds immediately when run.

    succeed 42    -- results in 42
-}
succeed : a -> Task x a
succeed =
  Native.Scheduler.succeed


{-| A task that fails immediately when run.

    fail "file not found" : Task String a
-}
fail : x -> Task x a
fail =
  Native.Scheduler.fail



-- MAPPING


{-| Transform a task.

    map sqrt (succeed 9) -- succeed 3
-}
map : (a -> b) -> Task x a -> Task x b
map func taskA =
  taskA
    `andThen` \a -> succeed (func a)


{-| Put the results of two tasks together. If either task fails, the whole
thing fails. It also runs in order so the first task will be completely
finished before the second task starts.

    map2 (+) (succeed 9) (succeed 3) -- succeed 12
-}
map2 : (a -> b -> result) -> Task x a -> Task x b -> Task x result
map2 func taskA taskB =
  taskA
    `andThen` \a -> taskB
    `andThen` \b -> succeed (func a b)


{-|-}
map3 : (a -> b -> c -> result) -> Task x a -> Task x b -> Task x c -> Task x result
map3 func taskA taskB taskC =
  taskA
    `andThen` \a -> taskB
    `andThen` \b -> taskC
    `andThen` \c -> succeed (func a b c)


{-|-}
map4 : (a -> b -> c -> d -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x result
map4 func taskA taskB taskC taskD =
  taskA
    `andThen` \a -> taskB
    `andThen` \b -> taskC
    `andThen` \c -> taskD
    `andThen` \d -> succeed (func a b c d)


{-|-}
map5 : (a -> b -> c -> d -> e -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x e -> Task x result
map5 func taskA taskB taskC taskD taskE =
  taskA
    `andThen` \a -> taskB
    `andThen` \b -> taskC
    `andThen` \c -> taskD
    `andThen` \d -> taskE
    `andThen` \e -> succeed (func a b c d e)


{-| Put the results of two tasks together. If either task fails, the whole
thing fails. It also runs in order so the first task will be completely
finished before the second task starts.

This function makes it possible to chain tons of tasks together and pipe them
all into a single function.

    (f `map` task1 `andMap` task2 `andMap` task3) -- map3 f task1 task2 task3
-}
andMap : Task x (a -> b) -> Task x a -> Task x b
andMap taskFunc taskValue =
  taskFunc
    `andThen` \func -> taskValue
    `andThen` \value -> succeed (func value)


{-| Start with a list of tasks, and turn them into a single task that returns a
list. The tasks will be run in order one-by-one and if any task fails the whole
sequence fails.

    sequence [ succeed 1, succeed 2 ] -- succeed [ 1, 2 ]

This can be useful if you need to make a bunch of HTTP requests one-by-one.
-}
sequence : List (Task x a) -> Task x (List a)
sequence tasks =
  case tasks of
    [] ->
      succeed []

    task :: remainingTasks ->
      map2 (::) task (sequence remainingTasks)



-- CHAINING


{-| Chain together a task and a callback. The first task will run, and if it is
successful, you give the result to the callback resulting in another task. This
task then gets run.

    succeed 2 `andThen` (\n -> succeed (n + 2)) -- succeed 4

This is useful for chaining tasks together. Maybe you need to get a user from
your servers *and then* lookup their picture once you know their name.
-}
andThen : Task x a -> (a -> Task x b) -> Task x b
andThen =
  Native.Scheduler.andThen


-- ERRORS

{-| Recover from a failure in a task. If the given task fails, we use the
callback to recover.

    fail "file not found" `onError` (\msg -> succeed 42) -- succeed 42
    succeed 9 `onError` (\msg -> succeed 42)             -- succeed 9
-}
onError : Task x a -> (x -> Task y a) -> Task y a
onError =
  Native.Scheduler.onError


{-| Transform the error value. This can be useful if you need a bunch of error
types to match up.

    type Error = Http Http.Error | WebGL WebGL.Error

    getResources : Task Error Resource
    getResources =
      sequence [ mapError Http serverTask, mapError WebGL textureTask ]
-}
mapError : (x -> y) -> Task x a -> Task y a
mapError f task =
  task `onError` \err -> fail (f err)


{-| Translate a task that can fail into a task that can never fail, by
converting any failure into `Nothing` and any success into `Just` something.

    toMaybe (fail "file not found") -- succeed Nothing
    toMaybe (succeed 42)            -- succeed (Just 42)

This means you can handle the error with the `Maybe` module instead.
-}
toMaybe : Task x a -> Task never (Maybe a)
toMaybe task =
  map Just task `onError` (\_ -> succeed Nothing)


{-| If you are chaining together a bunch of tasks, it may be useful to treat
a maybe value like a task.

    fromMaybe "file not found" Nothing   -- fail "file not found"
    fromMaybe "file not found" (Just 42) -- succeed 42
-}
fromMaybe : x -> Maybe a -> Task x a
fromMaybe default maybe =
  case maybe of
    Just value ->
      succeed value

    Nothing ->
      fail default


{-| Translate a task that can fail into a task that can never fail, by
converting any failure into `Err` something and any success into `Ok` something.

    toResult (fail "file not found") -- succeed (Err "file not found")
    toResult (succeed 42)            -- succeed (Ok 42)

This means you can handle the error with the `Result` module instead.
-}
toResult : Task x a -> Task never (Result x a)
toResult task =
  map Ok task `onError` (\msg -> succeed (Err msg))


{-| If you are chaining together a bunch of tasks, it may be useful to treat
a result like a task.

    fromResult (Err "file not found") -- fail "file not found"
    fromResult (Ok 42)                -- succeed 42
-}
fromResult : Result x a -> Task x a
fromResult result =
  case result of
    Ok value ->
      succeed value

    Err msg ->
      fail msg



-- COMMANDS


type MyCmd msg =
  T (Task Never msg)


{-| Command the runtime system to perform a task. The most important argument
is the `Task` which describes what you want to happen. But you also need to
provide functions to tag the two possible outcomes of the task. It can fail or
succeed, but either way, you need to have a message to feed back into your
application.
-}
perform : (x -> msg) -> (a -> msg) -> Task x a -> Cmd msg
perform onFail onSuccess task =
  command (T (map onSuccess task `onError` \x -> succeed (onFail x)))


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap tagger (T task) =
  T (map tagger task)



-- MANAGER


init : Task Never ()
init =
  succeed ()


onEffects : Platform.Router msg Never -> List (MyCmd msg) -> () -> Task Never ()
onEffects router commands state =
  map
    (\_ -> ())
    (sequence (List.map (spawnCmd router) commands))


onSelfMsg : Platform.Router msg Never -> Never -> () -> Task Never ()
onSelfMsg _ _ _ =
  succeed ()


spawnCmd : Platform.Router msg Never -> MyCmd msg -> Task x ()
spawnCmd router (T task) =
  Native.Scheduler.spawn (task `andThen` Platform.sendToApp router)

