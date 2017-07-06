module Date exposing
  ( Date, fromIso8601, toTime, fromTime
  , year, month, Month(..)
  , day, dayOfWeek, Day(..)
  , hour, minute, second, millisecond
  , now
  )

{-| Library for working with dates. Email the mailing list if you encounter
issues with internationalization or locale formatting.

# Dates
@docs Date, now

# Conversions
@docs fromIso8601, toTime, fromTime

# Extractions
@docs year, month, Month, day, dayOfWeek, Day, hour, minute, second, millisecond

-}

import Elm.Kernel.Date
import Task exposing (Task)
import Time exposing (Time)
import Result exposing (Result)



-- DATES


{-| Representation of a date.
-}
type Date = Date


{-| Get the `Date` at the moment when this task is run.
-}
now : Task x Date
now =
  Task.map fromTime Time.now



-- CONVERSIONS AND EXTRACTIONS


{-| Represents the days of the week.
-}
type Day = Mon | Tue | Wed | Thu | Fri | Sat | Sun


{-| Represents the month of the year.
-}
type Month
    = Jan | Feb | Mar | Apr
    | May | Jun | Jul | Aug
    | Sep | Oct | Nov | Dec


{-| Turn a `Date` into a `String` in [the ISO 8601 format][iso].

[iso]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.9.1.15
-}
toIso8601 : Date -> String
toIso8601 =
  Elm.Kernel.Date.toIso8601


{-| Attempt to read `String` values in [the ISO 8601 format][iso].

[iso]: http://www.ecma-international.org/ecma-262/5.1/#sec-15.9.1.15

    fromIso8601 "1990"                      == Ok ...
    fromIso8601 "1990-09"                   == Ok ...
    fromIso8601 "1990-09-15"                == Ok ...
    fromIso8601 "1990/09/15"                == Err ...

    fromIso8601 "1990T08:30"                == Ok ...
    fromIso8601 "1990-09T14:15"             == Ok ...
    fromIso8601 "1990-09-15T14:15:06"       == Ok ...
    fromIso8601 "1990-09-15T14:15:06.123"   == Ok ...
    fromIso8601 "1990-09-15T14:15:06.12"    == Err ...

    fromIso8601 "1990T08:30Z"               == Ok ...
    fromIso8601 "1990T08:30-07:00"          == Ok ...
    fromIso8601 "1990T08:30+13:00"          == Ok ...
    fromIso8601 "1990T08:30+25:00"          == Err ...
-}
fromIso8601 : String -> Result String Date
fromIso8601 =
  Elm.Kernel.Date.fromIso8601


{-| Convert a `Date` to a time in milliseconds.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).
-}
toTime : Date -> Time
toTime =
  Elm.Kernel.Date.toTime


{-| Convert a time in milliseconds into a `Date`.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).
-}
fromTime : Time -> Date
fromTime =
  Elm.Kernel.Date.fromTime


{-| Extract the year of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `1990`.
-}
year : Date -> Int
year =
  Elm.Kernel.Date.year


{-| Extract the month of a given date. Given the date 23 June 1990 at 11:45AM
this returns the month `Jun` as defined below.
-}
month : Date -> Month
month =
  Elm.Kernel.Date.month


{-| Extract the day of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `23`.
-}
day : Date -> Int
day =
  Elm.Kernel.Date.day


{-| Extract the day of the week for a given date. Given the date 23 June
1990 at 11:45AM this returns the day `Sat` as defined below.
-}
dayOfWeek : Date -> Day
dayOfWeek =
  Elm.Kernel.Date.dayOfWeek


{-| Extract the hour of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `11`.
-}
hour : Date -> Int
hour =
  Elm.Kernel.Date.hour


{-| Extract the minute of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `45`.
-}
minute : Date -> Int
minute =
  Elm.Kernel.Date.minute


{-| Extract the second of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `0`.
-}
second : Date -> Int
second =
  Elm.Kernel.Date.second


{-| Extract the millisecond of a given date. Given the date 23 June 1990 at 11:45:30.123AM
this returns the integer `123`.
-}
millisecond : Date -> Int
millisecond =
  Elm.Kernel.Date.millisecond
