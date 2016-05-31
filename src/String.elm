module String exposing
  ( isEmpty, length, reverse, repeat
  , cons, uncons, fromChar, append, concat, split, join, words, lines
  , slice, left, right, dropLeft, dropRight
  , contains, startsWith, endsWith, indexes, indices
  , toInt, toFloat, toList, fromList
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

# Conversions
@docs toInt, toFloat, toList, fromList

# Formatting
Cosmetic operations such as padding with extra characters or trimming whitespace.

@docs toUpper, toLower,
      pad, padLeft, padRight,
      trim, trimLeft, trimRight

# Higher-Order Functions
@docs map, filter, foldl, foldr, any, all
-}

import Native.String
import Char
import Maybe exposing (Maybe)
import Result exposing (Result)


{-| Determine if a string is empty.

    isEmpty "" == True
    isEmpty "the world" == False
-}
isEmpty : String -> Bool
isEmpty =
  Native.String.isEmpty


{-| Add a character to the beginning of a string.

    cons 'T' "he truth is out there" == "The truth is out there"
-}
cons : Char -> String -> String
cons =
  Native.String.cons


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
  Native.String.uncons


{-| Append two strings. You can also use [the `(++)` operator](Basics#++)
to do this.

    append "butter" "fly" == "butterfly"
-}
append : String -> String -> String
append =
  Native.String.append


{-| Concatenate many strings into one.

    concat ["never","the","less"] == "nevertheless"
-}
concat : List String -> String
concat =
  Native.String.concat


{-| Get the length of a string.

    length "innumerable" == 11
    length "" == 0

-}
length : String -> Int
length =
  Native.String.length


{-| Transform every character in a string

    map (\c -> if c == '/' then '.' else c) "a/b/c" == "a.b.c"
-}
map : (Char -> Char) -> String -> String
map =
  Native.String.map


{-| Keep only the characters that satisfy the predicate.

    filter isDigit "R2-D2" == "22"
-}
filter : (Char -> Bool) -> String -> String
filter =
  Native.String.filter


{-| Reverse a string.

    reverse "stressed" == "desserts"
-}
reverse : String -> String
reverse =
  Native.String.reverse


{-| Reduce a string from the left.

    foldl cons "" "time" == "emit"
-}
foldl : (Char -> b -> b) -> b -> String -> b
foldl =
  Native.String.foldl


{-| Reduce a string from the right.

    foldr cons "" "time" == "time"
-}
foldr : (Char -> b -> b) -> b -> String -> b
foldr =
  Native.String.foldr


{-| Split a string using a given separator.

    split "," "cat,dog,cow"        == ["cat","dog","cow"]
    split "/" "home/evan/Desktop/" == ["home","evan","Desktop", ""]

Use [`Regex.split`](Regex#split) if you need something more flexible.
-}
split : String -> String -> List String
split =
  Native.String.split


{-| Put many strings together with a given separator.

    join "a" ["H","w","ii","n"]        == "Hawaiian"
    join " " ["cat","dog","cow"]       == "cat dog cow"
    join "/" ["home","evan","Desktop"] == "home/evan/Desktop"
-}
join : String -> List String -> String
join =
  Native.String.join


{-| Repeat a string *n* times.

    repeat 3 "ha" == "hahaha"
-}
repeat : Int -> String -> String
repeat =
  Native.String.repeat


{-| Take a substring given a start and end index. Negative indexes
are taken starting from the *end* of the list.

    slice  7  9 "snakes on a plane!" == "on"
    slice  0  6 "snakes on a plane!" == "snakes"
    slice  0 -7 "snakes on a plane!" == "snakes on a"
    slice -6 -1 "snakes on a plane!" == "plane"
-}
slice : Int -> Int -> String -> String
slice =
  Native.String.slice


{-| Take *n* characters from the left side of a string.

    left 2 "Mulder" == "Mu"
-}
left : Int -> String -> String
left =
  Native.String.left


{-| Take *n* characters from the right side of a string.

    right 2 "Scully" == "ly"
-}
right : Int -> String -> String
right =
  Native.String.right


{-| Drop *n* characters from the left side of a string.

    dropLeft 2 "The Lone Gunmen" == "e Lone Gunmen"
-}
dropLeft : Int -> String -> String
dropLeft =
  Native.String.dropLeft


{-| Drop *n* characters from the right side of a string.

    dropRight 2 "Cigarette Smoking Man" == "Cigarette Smoking M"
-}
dropRight : Int -> String -> String
dropRight =
  Native.String.dropRight


{-| Pad a string on both sides until it has a given length.

    pad 5 ' ' "1"   == "  1  "
    pad 5 ' ' "11"  == "  11 "
    pad 5 ' ' "121" == " 121 "
-}
pad : Int -> Char -> String -> String
pad =
  Native.String.pad


{-| Pad a string on the left until it has a given length.

    padLeft 5 '.' "1"   == "....1"
    padLeft 5 '.' "11"  == "...11"
    padLeft 5 '.' "121" == "..121"
-}
padLeft : Int -> Char -> String -> String
padLeft =
  Native.String.padLeft


{-| Pad a string on the right until it has a given length.

    padRight 5 '.' "1"   == "1...."
    padRight 5 '.' "11"  == "11..."
    padRight 5 '.' "121" == "121.."
-}
padRight : Int -> Char -> String -> String
padRight =
  Native.String.padRight


{-| Get rid of whitespace on both sides of a string.

    trim "  hats  \n" == "hats"
-}
trim : String -> String
trim =
  Native.String.trim


{-| Get rid of whitespace on the left of a string.

    trimLeft "  hats  \n" == "hats  \n"
-}
trimLeft : String -> String
trimLeft =
  Native.String.trimLeft


{-| Get rid of whitespace on the right of a string.

    trimRight "  hats  \n" == "  hats"
-}
trimRight : String -> String
trimRight =
  Native.String.trimRight


{-| Break a string into words, splitting on chunks of whitespace.

    words "How are \t you? \n Good?" == ["How","are","you?","Good?"]
-}
words : String -> List String
words =
  Native.String.words


{-| Break a string into lines, splitting on newlines.

    lines "How are you?\nGood?" == ["How are you?", "Good?"]
-}
lines : String -> List String
lines =
  Native.String.lines


{-| Convert a string to all upper case. Useful for case-insensitive comparisons
and VIRTUAL YELLING.

    toUpper "skinner" == "SKINNER"
-}
toUpper : String -> String
toUpper =
  Native.String.toUpper


{-| Convert a string to all lower case. Useful for case-insensitive comparisons.

    toLower "X-FILES" == "x-files"
-}
toLower : String -> String
toLower =
  Native.String.toLower


{-| Determine whether *any* characters satisfy a predicate.

    any isDigit "90210" == True
    any isDigit "R2-D2" == True
    any isDigit "heart" == False
-}
any : (Char -> Bool) -> String -> Bool
any =
  Native.String.any


{-| Determine whether *all* characters satisfy a predicate.

    all isDigit "90210" == True
    all isDigit "R2-D2" == False
    all isDigit "heart" == False
-}
all : (Char -> Bool) -> String -> Bool
all =
  Native.String.all


{-| See if the second string contains the first one.

    contains "the" "theory" == True
    contains "hat" "theory" == False
    contains "THE" "theory" == False

Use [`Regex.contains`](Regex#contains) if you need something more flexible.
-}
contains : String -> String -> Bool
contains =
  Native.String.contains


{-| See if the second string starts with the first one.

    startsWith "the" "theory" == True
    startsWith "ory" "theory" == False
-}
startsWith : String -> String -> Bool
startsWith =
  Native.String.startsWith


{-| See if the second string ends with the first one.

    endsWith "the" "theory" == False
    endsWith "ory" "theory" == True
-}
endsWith : String -> String -> Bool
endsWith =
  Native.String.endsWith


{-| Get all of the indexes for a substring in another string.

    indexes "i" "Mississippi"   == [1,4,7,10]
    indexes "ss" "Mississippi"  == [2,5]
    indexes "needle" "haystack" == []
-}
indexes : String -> String -> List Int
indexes =
  Native.String.indexes


{-| Alias for `indexes`. -}
indices : String -> String -> List Int
indices =
  Native.String.indexes


{-| Try to convert a string into an int, failing on improperly formatted strings.

    String.toInt "123" == Ok 123
    String.toInt "-42" == Ok -42
    String.toInt "3.1" == Err "could not convert string '3.1' to an Int"
    String.toInt "31a" == Err "could not convert string '31a' to an Int"

If you are extracting a number from some raw user input, you will typically
want to use [`Result.withDefault`](Result#withDefault) to handle bad data:

    Result.withDefault 0 (String.toInt "42") == 42
    Result.withDefault 0 (String.toInt "ab") == 0
-}
toInt : String -> Result String Int
toInt =
  Native.String.toInt


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
  Native.String.toFloat


{-| Convert a string to a list of characters.

    toList "abc" == ['a','b','c']
-}
toList : String -> List Char
toList =
  Native.String.toList


{-| Convert a list of characters into a String. Can be useful if you
want to create a string primarily by consing, perhaps for decoding
something.

    fromList ['a','b','c'] == "abc"
-}
fromList : List Char -> String
fromList =
  Native.String.fromList

