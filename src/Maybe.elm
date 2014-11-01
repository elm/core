module Maybe (Maybe(Just,Nothing), andThen, map, withDefault) where

{-| This library fills a bunch of important niches in Elm. A `Maybe` can help
you with optional arguments, error handling, and records with optional fields.

# Definition
@docs Maybe

# Extracting Values
@docs withDefault

# Chaining Maybes
@docs map, andThen

-}

{-| Represent values that may or may not exist. It can be useful if you have a
record field that is only filled in sometimes. Or if a function takes a value
sometimes, but does not absolutely need it. It can also be used to represent
functions that can fail.

      -- A person, but maybe we do not know their age.
      type alias Person =
          { name : String
          , age : Maybe Int
          }

          -- tom = { name = "Tom", age = Just 42 }
          -- sue = { name = "Sue", age = Nothing }

      -- a function that might not succeed
      String.toInt : String -> Maybe Int

          -- String.toInt "hats" == Nothing
          -- String.toInt "123" == Just 123
-}
type Maybe a = Just a | Nothing


{-| Provide a default value, turning an optional value into a normal value.
This comes in handy when paired with functions like `Dict.get` which gives back
a `Maybe`.

      withDefault 100 (Just 42) == 42
      withDefault 100 Nothing == 100

      withDefault "plumber" (Dict.get "Tom" Dict.empty) == "plumber"
-}
withDefault : a -> Maybe a -> a
withDefault default optional =
    case optional of
      Just value -> value
      Nothing -> default


{-| Transform an `Maybe` value with a given function:

      map sqrt (Just 9) == Just 3
      map sqrt Nothing == Nothing
-}
map : (a -> b) -> Maybe a -> Maybe b
map f maybe =
    case maybe of
      Just value -> Just (f value)
      Nothing -> Nothing


{-| Chain together many computations that may fail. It is helpful to see its
definition:

      andThen : Maybe a -> (a -> Maybe b) -> Maybe b
      andThen maybe callback =
          case maybe of
            Just value -> callback value
            Nothing -> Nothing

This means we only continue with the callback if things are going well. For
example, say you need to use (`toInt : String -> Maybe Int`) to parse a month
and make sure it is between 1 and 12:

      validMonth : Int -> Maybe Int
      validMonth month =
          if month >= 1 && month <= 12
              then Just month
              else Nothing

      toMonth : String -> Maybe Int
      toMonth rawString =
          toInt rawString `andThen` validMonth

If `toInt` fails and results in `Nothing` this entire chain of operations will
short-circuit and result in `Nothing`. If `validMonth` results in `Nothing`,
again the chain of computations will result in `Nothing`.
-}
andThen : Maybe a -> (a -> Maybe b) -> Maybe b
andThen maybeValue callback =
    case maybeValue of
        Just value -> callback value
        Nothing -> Nothing
