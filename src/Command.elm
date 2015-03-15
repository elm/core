module Command
    ( Command
    , succeed, fail
    , map, map2, map3, map4, map5, andMap
    , sequence
    , andThen
    , onError, mapError
    , ID, spawn, sleep
    ) where
{-|

# Basics
@docs succeed, fail

# Mapping
@docs map, map2, map3, map4, map5, andMap

# Chaining
@docs andThen, sequence

# Errors
@docs onError, mapError

# Threads
@docs spawn, sleep
-}

import Native.Command
import List exposing ((::))
import Result exposing (Result)
import Signal exposing (Stream)
import Time exposing (Time)


type Command x a = Command


-- BASICS

succeed : a -> Command x a
succeed =
  Native.Command.succeed


fail : x -> Command x a
fail =
  Native.Command.fail


-- MAPPING

map : (a -> b) -> Command x a -> Command x b
map func promiseA =
  promiseA
    `andThen` \a -> succeed (func a)


map2 : (a -> b -> result) -> Command x a -> Command x b -> Command x result
map2 func promiseA promiseB =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> succeed (func a b)


map3 : (a -> b -> c -> result) -> Command x a -> Command x b -> Command x c -> Command x result
map3 func promiseA promiseB promiseC =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> succeed (func a b c)


map4 : (a -> b -> c -> d -> result) -> Command x a -> Command x b -> Command x c -> Command x d -> Command x result
map4 func promiseA promiseB promiseC promiseD =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> succeed (func a b c d)


map5 : (a -> b -> c -> d -> e -> result) -> Command x a -> Command x b -> Command x c -> Command x d -> Command x e -> Command x result
map5 func promiseA promiseB promiseC promiseD promiseE =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> promiseE
    `andThen` \e -> succeed (func a b c d e)


andMap : Command x (a -> b) -> Command x a -> Command x b
andMap promiseFunc promiseValue =
  promiseFunc
    `andThen` \func -> promiseValue
    `andThen` \value -> succeed (func value)


sequence : List (Command x a) -> Command x (List a)
sequence promises =
  case promises of
    [] ->
        succeed []

    promise :: remainingCommands ->
        map2 (::) promise (sequence remainingCommands)


-- interleave : List (Command x a) -> Command x (List a)



-- CHAINING

andThen : Command x a -> (a -> Command x b) -> Command x b
andThen =
  Native.Command.andThen


-- ERRORS

onError : Command x a -> (x -> Command y a) -> Command y a
onError =
  Native.Command.catch_


mapError : (x -> y) -> Command x a -> Command y a
mapError f promise =
  promise `onError` \err -> fail (f err)


-- THREADS

type ID = ID Int


spawn : Command x a -> Command y ID
spawn =
  Native.Command.spawn


-- kill : ID -> Command x ()


sleep : Time -> Command x ()
sleep =
  Native.Command.sleep
