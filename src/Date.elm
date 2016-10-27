module Date exposing
  ( Date, fromString, toTime, fromTime
  , year, month, Month(..)
  , day, dayOfWeek, Day(..)
  , hour, minute, second, millisecond
  , utcYear, utcMonth
  , utcDay, utcDayOfWeek
  , utcHour, utcMinute, utcSecond, utcMillisecond
  , timezoneOffset
  , now
  )

{-| Library for working with dates. Email the mailing list if you encounter
issues with internationalization or locale formatting.

# Dates
@docs Date, now

# Conversions
@docs fromString, toTime, fromTime

# Extractions
@docs year, month, Month, day, dayOfWeek, Day, hour, minute, second, millisecond, utcYear, utcMonth, utcDay, utcDayOfWeek, utcHour, utcMinute, utcSecond, utcMillisecond, timezoneOffset

-}

import Native.Date
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


{-| Attempt to read a date from a string.
-}
fromString : String -> Result String Date
fromString =
  Native.Date.fromString


{-| Convert a `Date` to a time in milliseconds.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).
-}
toTime : Date -> Time
toTime =
  Native.Date.toTime


{-| Convert a time in milliseconds into a `Date`.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).
-}
fromTime : Time -> Date
fromTime =
  Native.Date.fromTime


{-| Extract the year of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `1990`.
-}
year : Date -> Int
year =
  Native.Date.year


{-| Extract the month of a given date. Given the date 23 June 1990 at 11:45AM
this returns the month `Jun` as defined below.
-}
month : Date -> Month
month =
  Native.Date.month


{-| Extract the day of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `23`.
-}
day : Date -> Int
day =
  Native.Date.day


{-| Extract the day of the week for a given date. Given the date 23 June
1990 at 11:45AM this returns the day `Sat` as defined below.
-}
dayOfWeek : Date -> Day
dayOfWeek =
  Native.Date.dayOfWeek


{-| Extract the hour of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `11`.
-}
hour : Date -> Int
hour =
  Native.Date.hour


{-| Extract the minute of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `45`.
-}
minute : Date -> Int
minute =
  Native.Date.minute


{-| Extract the second of a given date. Given the date 23 June 1990 at 11:45AM
this returns the integer `0`.
-}
second : Date -> Int
second =
  Native.Date.second


{-| Extract the millisecond of a given date. Given the date 23 June 1990 at
11:45:30.123AM this returns the integer `123`.
-}
millisecond : Date -> Int
millisecond =
  Native.Date.millisecond

{-| Extract the year of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the integer `1990`.
-}
utcYear : Date -> Int
utcYear =
  Native.Date.utcYear


{-| Extract the month of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the month `Jun` as defined below.
-}
utcMonth : Date -> Month
utcMonth =
  Native.Date.utcMonth


{-| Extract the day of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the integer `23`.
-}
utcDay : Date -> Int
utcDay =
  Native.Date.utcDay


{-| Extract the day of the week for a given date when localized to UTC. Given
the date 23 June 1990 at 11:45AM UTC this returns the day `Sat` as defined
below.
-}
utcDayOfWeek : Date -> Day
utcDayOfWeek =
  Native.Date.utcDayOfWeek


{-| Extract the hour of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the integer `11`.
-}
utcHour : Date -> Int
utcHour =
  Native.Date.utcHour


{-| Extract the minute of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the integer `45`.
-}
utcMinute : Date -> Int
utcMinute =
  Native.Date.utcMinute


{-| Extract the second of a given date when localized to UTC. Given the date 23
June 1990 at 11:45AM UTC this returns the integer `0`.
-}
utcSecond : Date -> Int
utcSecond =
  Native.Date.utcSecond


{-| Extract the millisecond of a given date when localized to UTC. Given the
date 23 June 1990 at 11:45:30.123AM UTC this returns the integer `123`.
-}
utcMillisecond : Date -> Int
utcMillisecond =
  Native.Date.utcMillisecond


{-| Extract the number of minutes between the timezone in the date and UTC.
Given the date 23 June 1990 at 11:45AM EDT this returns the integer `240`.
-}
timezoneOffset : Date -> Int
timezoneOffset =
  Native.Date.timezoneOffset
