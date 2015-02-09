module Promise where
{-|

# Basics
@docs succeed, fail

# Mapping
@docs map, map2, map3, map4, map5, apply

# Chaining
@docs andThen

# Errors
@docs catch, mapError

-}

import Native.Promise


type Promise x a = Promise

run : a -> Signal (Promise x a) -> Signal (Result x a)
run =
  Native.Promise.run


-- BASICS

succeed : a -> Promise x a
succeed =
  Native.Promise.succeed


fail : x -> Promise x a
fail =
  Native.Promise.fail


-- MAPPING

map : (a -> b) -> Promise x a -> Promise x b
map func promiseA =
  promiseA
    `andThen` \a -> succeed (func a)


map2 : (a -> b -> result) -> Promise x a -> Promise x b -> Promise x result
map2 func promiseA promiseB =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> succeed (func a b)


map3 : (a -> b -> c -> result) -> Promise x a -> Promise x b -> Promise x c -> Promise x result
map3 func promiseA promiseB promiseC =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> succeed (func a b c)


map4 : (a -> b -> c -> d -> result) -> Promise x a -> Promise x b -> Promise x c -> Promise x d -> Promise x result
map4 func promiseA promiseB promiseC promiseD =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> succeed (func a b c d)


map5 : (a -> b -> c -> d -> e -> result) -> Promise x a -> Promise x b -> Promise x c -> Promise x d -> Promise x e -> Promise x result
map5 func promiseA promiseB promiseC promiseD promiseE =
  promiseA
    `andThen` \a -> promiseB
    `andThen` \b -> promiseC
    `andThen` \c -> promiseD
    `andThen` \d -> promiseE
    `andThen` \e -> succeed (func a b c d e)


apply : Promise x (a -> b) -> Promise x a -> Promise x b
apply promiseFunc promiseValue =
  promiseFunc
    `andThen` \func -> promiseValue
    `andThen` \value -> succeed (func value)


sequence : List (Promise x a) -> Promise x (List a)
sequence promises =
  case promises of
    [] ->
        succeed []

    promise :: remainingPromises ->
        map2 (::) promise (sequence remainingPromises)


-- interleave : List (Promise x a) -> Promise x (List a)



-- CHAINING

andThen : Promise x a -> (a -> Promise x b) -> Promise x b
andThen =
  Native.Promise.andThen


-- ERRORS

onError : Promise x a -> (x -> Promise y a) -> Promise y a
onError =
  Native.Promise.catch_


mapError : (x -> y) -> Promise x a -> Promise y a
mapError f promise =
  promise `onError` \err -> fail (f err)


-- THREADS

-- spawn : Promise x a -> Promise y ID

-- kill : ID -> Promise x ()

-- sleep : Time -> Promise x ()


-- TESTING

print : String -> Promise x ()
print =
  Native.Promise.print
