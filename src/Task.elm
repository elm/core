effect module Task where { command = MyCmd } exposing
  ( Task
  , succeed, fail
  , map, map2, map3, map4, map5
  , sequence
  , andThen
  , onError, mapError
  , perform, attempt
  )

{-| Tasks make it easy to describe asynchronous operations that may fail, like
HTTP requests or writing to a database. For more information, see the [Elm
documentation on Tasks](http://guide.elm-lang.org/error_handling/task.html).

# Basics
@docs Task, succeed, fail

# Mapping
@docs map, map2, map3, map4, map5

# Chaining
@docs andThen, sequence

# Errors
@docs onError, mapError

# Commands
@docs perform, attempt

-}

import Basics exposing (Never, (|>), (<<))
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
    |> andThen (\a -> succeed (func a))


{-| Put the results of two tasks together. If either task fails, the whole
thing fails. It also runs in order so the first task will be completely
finished before the second task starts.

    map2 (+) (succeed 9) (succeed 3) -- succeed 12
-}
map2 : (a -> b -> result) -> Task x a -> Task x b -> Task x result
map2 func taskA taskB =
  taskA
    |> andThen (\a -> taskB
    |> andThen (\b -> succeed (func a b)))


{-|-}
map3 : (a -> b -> c -> result) -> Task x a -> Task x b -> Task x c -> Task x result
map3 func taskA taskB taskC =
  taskA
    |> andThen (\a -> taskB
    |> andThen (\b -> taskC
    |> andThen (\c -> succeed (func a b c))))


{-|-}
map4 : (a -> b -> c -> d -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x result
map4 func taskA taskB taskC taskD =
  taskA
    |> andThen (\a -> taskB
    |> andThen (\b -> taskC
    |> andThen (\c -> taskD
    |> andThen (\d -> succeed (func a b c d)))))


{-|-}
map5 : (a -> b -> c -> d -> e -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x e -> Task x result
map5 func taskA taskB taskC taskD taskE =
  taskA
    |> andThen (\a -> taskB
    |> andThen (\b -> taskC
    |> andThen (\c -> taskD
    |> andThen (\d -> taskE
    |> andThen (\e -> succeed (func a b c d e))))))


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

    succeed 2
      |> andThen (\n -> succeed (n + 2))
      -- succeed 4

This is useful for chaining tasks together. Maybe you need to get a user from
your servers *and then* lookup their picture once you know their name.
-}
andThen : (a -> Task x b) -> Task x a -> Task x b
andThen =
  Native.Scheduler.andThen


-- ERRORS

{-| Recover from a failure in a task. If the given task fails, we use the
callback to recover.

    fail "file not found"
      |> onError (\msg -> succeed 42)
      -- succeed 42

    succeed 9
      |> onError (\msg -> succeed 42)
      -- succeed 9
-}
onError : (x -> Task y a) -> Task x a -> Task y a
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
mapError convert task =
  task
    |> onError (fail << convert)



-- COMMANDS


type MyCmd msg =
  Perform (Task Never msg)


{-| The only way to *do* things in Elm is to give commands to the Elm runtime.
So we describe some complex behavior with a `Task` and then command the runtime
to `perform` that task. For example, getting the current time looks like this:

    import Task
    import Time exposing (Time)

    type Msg = Click | NewTime Time

    update : Msg -> Model -> Model
    update msg model =
      case msg of
        Click ->
          ( model, Task.perform NewTime Time.now )

        NewTime time ->
          ...
-}
perform : (a -> msg) -> Task Never a -> Cmd msg
perform toMessage task =
  command (Perform (map toMessage task))


{-| Command the Elm runtime to attempt a task that might fail!
-}
attempt : (Result x a -> msg) -> Task x a -> Cmd msg
attempt resultToMessage task =
  command (Perform (
    task
      |> andThen (succeed << resultToMessage << Ok)
      |> onError (succeed << resultToMessage << Err)
  ))


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap tagger (Perform task) =
  Perform (map tagger task)



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
spawnCmd router (Perform task) =
  Native.Scheduler.spawn (
    task
      |> andThen (Platform.sendToApp router)
  )

