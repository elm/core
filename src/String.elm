module String exposing
  ( isEmpty, length, reverse, repeat
  , cons, uncons, fromChar, append, concat, split, join, words, lines
  , slice, left, right, dropLeft, dropRight
  , contains, startsWith, endsWith, indexes, indices
  , toInt, fromInt
  , toFloat, fromFloat
  , toList, fromList
  , toUpper, toLower, pad, padLeft, padRight, trim, trimLeft, trimRight
  , map, filter, foldl, foldr, any, all
  )

{-| A built-in representation for efficient string manipulation. String literals
are enclosed in `"double quotes"`. Strings are *not* lists of characters.

# Basics
@docs isEmpty, length, reverse, repeat

# Building and Splitting
@docs cons, uncons, fromChar, append, concat, split, join, words, lines

# Get Substrings
@docs slice, left, right, dropLeft, dropRight

# Check for Substrings
@docs contains, startsWith, endsWith, indexes, indices

# Int Conversions
@docs toInt, fromInt

# Float Conversions
@docs toFloat, fromFloat

# List Conversions
@docs toList, fromList

# Formatting
Cosmetic operations such as padding with extra characters or trimming whitespace.

@docs toUpper, toLower,
      pad, padLeft, padRight,
      trim, trimLeft, trimRight

# Higher-Order Functions
@docs map, filter, foldl, foldr, any, all
-}

import Char
import Elm.Kernel.List
import Elm.Kernel.String
import List exposing ((::))
import Maybe exposing (Maybe)
import Result exposing (Result)


{-| Determine if a string is empty.

    isEmpty "" == True
    isEmpty "the world" == False
-}
isEmpty : String -> Bool
isEmpty =
  Elm.Kernel.String.isEmpty


{-| Add a character to the beginning of a string.

    cons 'T' "he truth is out there" == "The truth is out there"
-}
cons : Char -> String -> String
cons =
  Elm.Kernel.String.cons


{-| Create a string from a given character.

    fromChar 'a' == "a"
-}
fromChar : Char -> String
fromChar char =
  cons char ""


{-| Split a non-empty string into its head and tail. This lets you
pattern match on strings exactly as you would with lists.

    uncons "abc" == Just ('a',"bc")
    uncons ""    == Nothing
-}
uncons : String -> Maybe (Char, String)
uncons =
  Elm.Kernel.String.uncons


{-| Append two strings. You can also use [the `(++)` operator](Basics#++)
to do this.

    append "butter" "fly" == "butterfly"
-}
append : String -> String -> String
append =
  Elm.Kernel.String.append


{-| Concatenate many strings into one.

    concat ["never","the","less"] == "nevertheless"
-}
concat : List String -> String
concat strings =
  join "" strings


{-| Get the length of a string.

    length "innumerable" == 11
    length "" == 0

-}
length : String -> Int
length =
  Elm.Kernel.String.length


{-| Transform every character in a string

    map (\c -> if c == '/' then '.' else c) "a/b/c" == "a.b.c"
-}
map : (Char -> Char) -> String -> String
map =
  Elm.Kernel.String.map


{-| Keep only the characters that satisfy the predicate.

    filter isDigit "R2-D2" == "22"
-}
filter : (Char -> Bool) -> String -> String
filter =
  Elm.Kernel.String.filter


{-| Reverse a string.

    reverse "stressed" == "desserts"
-}
reverse : String -> String
reverse =
  Elm.Kernel.String.reverse


{-| Reduce a string from the left.

    foldl cons "" "time" == "emit"
-}
foldl : (Char -> b -> b) -> b -> String -> b
foldl =
  Elm.Kernel.String.foldl


{-| Reduce a string from the right.

    foldr cons "" "time" == "time"
-}
foldr : (Char -> b -> b) -> b -> String -> b
foldr =
  Elm.Kernel.String.foldr


{-| Split a string using a given separator.

    split "," "cat,dog,cow"        == ["cat","dog","cow"]
    split "/" "home/evan/Desktop/" == ["home","evan","Desktop", ""]

-}
split : String -> String -> List String
split sep string =
  Elm.Kernel.List.fromArray (Elm.Kernel.String.split sep string)


{-| Put many strings together with a given separator.

    join "a" ["H","w","ii","n"]        == "Hawaiian"
    join " " ["cat","dog","cow"]       == "cat dog cow"
    join "/" ["home","evan","Desktop"] == "home/evan/Desktop"
-}
join : String -> List String -> String
join sep chunks =
  Elm.Kernel.String.join sep (Elm.Kernel.List.toArray chunks)


{-| Repeat a string *n* times.

    repeat 3 "ha" == "hahaha"
-}
repeat : Int -> String -> String
repeat =
  Elm.Kernel.String.repeat


{-| Take a substring given a start and end index. Negative indexes
are taken starting from the *end* of the list.

    slice  7  9 "snakes on a plane!" == "on"
    slice  0  6 "snakes on a plane!" == "snakes"
    slice  0 -7 "snakes on a plane!" == "snakes on a"
    slice -6 -1 "snakes on a plane!" == "plane"
-}
slice : Int -> Int -> String -> String
slice =
  Elm.Kernel.String.slice


{-| Take *n* characters from the left side of a string.

    left 2 "Mulder" == "Mu"
-}
left : Int -> String -> String
left =
  Elm.Kernel.String.left


{-| Take *n* characters from the right side of a string.

    right 2 "Scully" == "ly"
-}
right : Int -> String -> String
right =
  Elm.Kernel.String.right


{-| Drop *n* characters from the left side of a string.

    dropLeft 2 "The Lone Gunmen" == "e Lone Gunmen"
-}
dropLeft : Int -> String -> String
dropLeft =
  Elm.Kernel.String.dropLeft


{-| Drop *n* characters from the right side of a string.

    dropRight 2 "Cigarette Smoking Man" == "Cigarette Smoking M"
-}
dropRight : Int -> String -> String
dropRight =
  Elm.Kernel.String.dropRight


{-| Pad a string on both sides until it has a given length.

    pad 5 ' ' "1"   == "  1  "
    pad 5 ' ' "11"  == "  11 "
    pad 5 ' ' "121" == " 121 "
-}
pad : Int -> Char -> String -> String
pad =
  Elm.Kernel.String.pad


{-| Pad a string on the left until it has a given length.

    padLeft 5 '.' "1"   == "....1"
    padLeft 5 '.' "11"  == "...11"
    padLeft 5 '.' "121" == "..121"
-}
padLeft : Int -> Char -> String -> String
padLeft =
  Elm.Kernel.String.padLeft


{-| Pad a string on the right until it has a given length.

    padRight 5 '.' "1"   == "1...."
    padRight 5 '.' "11"  == "11..."
    padRight 5 '.' "121" == "121.."
-}
padRight : Int -> Char -> String -> String
padRight =
  Elm.Kernel.String.padRight


{-| Get rid of whitespace on both sides of a string.

    trim "  hats  \n" == "hats"
-}
trim : String -> String
trim =
  Elm.Kernel.String.trim


{-| Get rid of whitespace on the left of a string.

    trimLeft "  hats  \n" == "hats  \n"
-}
trimLeft : String -> String
trimLeft =
  Elm.Kernel.String.trimLeft


{-| Get rid of whitespace on the right of a string.

    trimRight "  hats  \n" == "  hats"
-}
trimRight : String -> String
trimRight =
  Elm.Kernel.String.trimRight


{-| Break a string into words, splitting on chunks of whitespace.

    words "How are \t you? \n Good?" == ["How","are","you?","Good?"]
-}
words : String -> List String
words =
  Elm.Kernel.String.words


{-| Break a string into lines, splitting on newlines.

    lines "How are you?\nGood?" == ["How are you?", "Good?"]
-}
lines : String -> List String
lines =
  Elm.Kernel.String.lines


{-| Convert a string to all upper case. Useful for case-insensitive comparisons
and VIRTUAL YELLING.

    toUpper "skinner" == "SKINNER"
-}
toUpper : String -> String
toUpper =
  Elm.Kernel.String.toUpper


{-| Convert a string to all lower case. Useful for case-insensitive comparisons.

    toLower "X-FILES" == "x-files"
-}
toLower : String -> String
toLower =
  Elm.Kernel.String.toLower


{-| Determine whether *any* characters satisfy a predicate.

    any isDigit "90210" == True
    any isDigit "R2-D2" == True
    any isDigit "heart" == False
-}
any : (Char -> Bool) -> String -> Bool
any =
  Elm.Kernel.String.any


{-| Determine whether *all* characters satisfy a predicate.

    all isDigit "90210" == True
    all isDigit "R2-D2" == False
    all isDigit "heart" == False
-}
all : (Char -> Bool) -> String -> Bool
all =
  Elm.Kernel.String.all


{-| See if the second string contains the first one.

    contains "the" "theory" == True
    contains "hat" "theory" == False
    contains "THE" "theory" == False

-}
contains : String -> String -> Bool
contains =
  Elm.Kernel.String.contains


{-| See if the second string starts with the first one.

    startsWith "the" "theory" == True
    startsWith "ory" "theory" == False
-}
startsWith : String -> String -> Bool
startsWith =
  Elm.Kernel.String.startsWith


{-| See if the second string ends with the first one.

    endsWith "the" "theory" == False
    endsWith "ory" "theory" == True
-}
endsWith : String -> String -> Bool
endsWith =
  Elm.Kernel.String.endsWith


{-| Get all of the indexes for a substring in another string.

    indexes "i" "Mississippi"   == [1,4,7,10]
    indexes "ss" "Mississippi"  == [2,5]
    indexes "needle" "haystack" == []
-}
indexes : String -> String -> List Int
indexes =
  Elm.Kernel.String.indexes


{-| Alias for `indexes`. -}
indices : String -> String -> List Int
indices =
  Elm.Kernel.String.indexes



-- INT CONVERSIONS


{-| Try to convert a string into an int, failing on improperly formatted strings.

    String.toInt "123" == Ok 123
    String.toInt "-42" == Ok -42
    String.toInt "3.1" == Err "could not convert string '3.1' to an Int"
    String.toInt "31a" == Err "could not convert string '31a' to an Int"

If you are extracting a number from some raw user input, you will typically
want to use [`Result.withDefault`](Result#withDefault) to handle bad data:

    Result.withDefault 0 (String.toInt "42") == 42
    Result.withDefault 0 (String.toInt "ab") == 0
    
Keep in mind that the strings "+" and "-" return Ok NaN.
You can test for NaN with [`Basics.isNaN`](Basics#isNaN).

    String.toInt "+" == Ok NaN
    String.toInt "-" == Ok NaN
-}
toInt : String -> Result String Int
toInt =
  Elm.Kernel.String.toInt


{-| Convert an `Int` to a `String`.

    String.fromInt 123 == "123"
    String.fromInt -42 == "-42"

Check out [`Debug.toString`](Debug#toString) to convert *any* value to a string
for debugging purposes.
-}
fromInt : Int -> String
fromInt =
  Elm.Kernel.String.fromNumber



-- FLOAT CONVERSIONS


{-| Try to convert a string into a float, failing on improperly formatted strings.

    String.toFloat "123" == Ok 123.0
    String.toFloat "-42" == Ok -42.0
    String.toFloat "3.1" == Ok 3.1
    String.toFloat "31a" == Err "could not convert string '31a' to a Float"

If you are extracting a number from some raw user input, you will typically
want to use [`Result.withDefault`](Result#withDefault) to handle bad data:

    Result.withDefault 0 (String.toFloat "42.5") == 42.5
    Result.withDefault 0 (String.toFloat "cats") == 0
-}
toFloat : String -> Result String Float
toFloat =
  Elm.Kernel.String.toFloat


{-| Convert a `Float` to a `String`.

    String.fromFloat 123 == "123"
    String.fromFloat -42 == "-42"
    String.fromFloat 3.9 == "3.9"

Check out [`Debug.toString`](Debug#toString) to convert *any* value to a string
for debugging purposes.
-}
fromFloat : Float -> String
fromFloat =
  Elm.Kernel.String.fromNumber



-- LIST CONVERSIONS


{-| Convert a string to a list of characters.

    toList "abc" == ['a','b','c']
    toList "🙈🙉🙊" == ['🙈','🙉','🙊']
-}
toList : String -> List Char
toList string =
  foldr (::) [] string


{-| Convert a list of characters into a String. Can be useful if you
want to create a string primarily by consing, perhaps for decoding
something.

    fromList ['a','b','c'] == "abc"
    fromList ['🙈','🙉','🙊'] == "🙈🙉🙊"
-}
fromList : List Char -> String
fromList =
  Elm.Kernel.String.fromList

