module Task
    ( Task
    , succeed, fail
    , map, map2, map3, map4, map5, andMap
    , sequence
    , andThen
    , onError, mapError
    , toMaybe, fromMaybe, toResult, fromResult
    , ThreadID, spawn, sleep
    ) where
{-|

# Basics
@docs succeed, fail

# Mapping
@docs map, map2, map3, map4, map5, andMap

# Chaining
@docs andThen, sequence

# Errors
@docs onError, mapError, toMaybe, fromMaybe, toResult, fromResult

# Threads
@docs spawn, sleep
-}

import Native.Task
import List exposing ((::))
import Maybe exposing (Maybe(Just,Nothing))
import Result exposing (Result(Ok,Err))


type Task x a = Task


-- BASICS

succeed : a -> Task x a
succeed =
  Native.Task.succeed


fail : x -> Task x a
fail =
  Native.Task.fail


-- MAPPING

map : (a -> b) -> Task x a -> Task x b
map func promiseA =
  promiseA
    `andThen` \a -> succeed (func a)


map2 : (a -> b -> result) -> Task x a -> Task x b -> Task x result
map2 func promiseA promiseB =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> succeed (func a b)


map3 : (a -> b -> c -> result) -> Task x a -> Task x b -> Task x c -> Task x result
map3 func promiseA promiseB promiseC =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> succeed (func a b c)


map4 : (a -> b -> c -> d -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x result
map4 func promiseA promiseB promiseC promiseD =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> succeed (func a b c d)


map5 : (a -> b -> c -> d -> e -> result) -> Task x a -> Task x b -> Task x c -> Task x d -> Task x e -> Task x result
map5 func promiseA promiseB promiseC promiseD promiseE =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> promiseE
    `andThen` \e -> succeed (func a b c d e)


andMap : Task x (a -> b) -> Task x a -> Task x b
andMap promiseFunc promiseValue =
  promiseFunc
    `andThen` \func -> promiseValue
    `andThen` \value -> succeed (func value)


sequence : List (Task x a) -> Task x (List a)
sequence promises =
  case promises of
    [] ->
        succeed []

    promise :: remainingTasks ->
        map2 (::) promise (sequence remainingTasks)


-- interleave : List (Task x a) -> Task x (List a)



-- CHAINING

andThen : Task x a -> (a -> Task x b) -> Task x b
andThen =
  Native.Task.andThen


-- ERRORS

onError : Task x a -> (x -> Task y a) -> Task y a
onError =
  Native.Task.catch_


mapError : (x -> y) -> Task x a -> Task y a
mapError f promise =
  promise `onError` \err -> fail (f err)


toMaybe : Task x a -> Task y (Maybe a)
toMaybe task =
  map Just task `onError` (\_ -> succeed Nothing)


fromMaybe : x -> Maybe a -> Task x a
fromMaybe default maybe =
  case maybe of
    Just value -> succeed value
    Nothing -> fail default


toResult : Task x a -> Task y (Result x a)
toResult task =
  map Ok task `onError` (\msg -> succeed (Err msg))


fromResult : Result x a -> Task x a
fromResult result =
  case result of
    Ok value -> succeed value
    Err msg -> fail msg


-- THREADS

type ThreadID = ThreadID Int


spawn : Task x a -> Task y ThreadID
spawn =
  Native.Task.spawn


-- kill : ThreadID -> Task x ()

type alias Time = Float


sleep : Time -> Task x ()
sleep =
  Native.Task.sleep



{-- TASK MANAGERS

type Manager

runOne : Task x a -> Manager

runSequential : Events (Task x a) -> Manager

runLatest : Events (Task x a) -> Manager

runConcurrent : Events (Task x a) -> Manager

--}
