module Basics exposing
  ( (+), (-), (*), (/), (//), (^)
  , toFloat, round, floor, ceiling, truncate
  , (==), (/=)
  , (<), (>), (<=), (>=), max, min, compare, Order(..)
  , not, (&&), (||), xor
  , (++)
  , modBy, remainderBy, negate, abs, clamp, sqrt, logBase, e
  , pi, cos, sin, tan, acos, asin, atan, atan2
  , degrees, radians, turns
  , toPolar, fromPolar
  , isNaN, isInfinite
  , identity, always, (<|), (|>), (<<), (>>), Never, never
  )

{-| Tons of useful functions that get imported by default.

# Math
@docs (+), (-), (*), (/), (//), (^)

# Int to Float / Float to Int
@docs toFloat, round, floor, ceiling, truncate

# Equality
@docs (==), (/=)

# Comparison

These functions only work on `comparable` types. This includes numbers,
characters, strings, lists of comparable things, and tuples of comparable
things. Note that tuples with 7 or more elements are not comparable. Why
are your tuples so big?

@docs (<), (>), (<=), (>=), max, min, compare, Order

# Booleans
@docs not, (&&), (||), xor

# Append Strings and Lists
@docs (++)

# Fancier Math
@docs modBy, remainderBy, negate, abs, clamp, sqrt, logBase, e

# Angles
@docs degrees, radians, turns

# Trigonometry
@docs pi, cos, sin, tan, acos, asin, atan, atan2

# Polar Coordinates
@docs toPolar, fromPolar

# Floating Point Checks
@docs isNaN, isInfinite

# Function Helpers
@docs identity, always, (<|), (|>), (<<), (>>), Never, never

-}


import Elm.Kernel.Basics
import Elm.Kernel.Utils



-- INFIX OPERATOR PRECEDENCE


infixr 0 <|
infixl 0 |>
infixr 2 ||
infixr 3 &&
infix  4 ==
infix  4 /=
infix  4 <
infix  4 >
infix  4 <=
infix  4 >=
infixr 5 ++
infixl 6 +
infixl 6 -
infixl 7 *
infixl 7 /
infixl 7 //
infixr 8 ^
infixr 9 <<
infixl 9 >>



-- MATHEMATICS


{-|-}
(+) : number -> number -> number
(+) =
  Elm.Kernel.Basics.add


{-|-}
(-) : number -> number -> number
(-) =
  Elm.Kernel.Basics.sub


{-|-}
(*) : number -> number -> number
(*) =
  Elm.Kernel.Basics.mul


{-| Floating point division. -}
(/) : Float -> Float -> Float
(/) =
  Elm.Kernel.Basics.fdiv


{-| Integer division. The remainder is discarded. -}
(//) : Int -> Int -> Int
(//) =
  Elm.Kernel.Basics.idiv


{-| Exponentiation

    3^2 == 9
-}
(^) : number -> number -> number
(^) =
  Elm.Kernel.Basics.exp



-- INT TO FLOAT / FLOAT TO INT


{-| Convert an integer into a float. -}
toFloat : Int -> Float
toFloat =
  Elm.Kernel.Basics.toFloat


{-| Round a number to the nearest integer. -}
round : Float -> Int
round =
  Elm.Kernel.Basics.round


{-| Floor function, rounding down. -}
floor : Float -> Int
floor =
  Elm.Kernel.Basics.floor


{-| Ceiling function, rounding up. -}
ceiling : Float -> Int
ceiling =
  Elm.Kernel.Basics.ceiling


{-| Truncate a number, rounding towards zero. -}
truncate : Float -> Int
truncate =
  Elm.Kernel.Basics.truncate



-- EQUALITY


{-| Check if values are &ldquo;the same&rdquo;.

**Note:** Elm uses structural equality on tuples, records, and user-defined
union types. This means the values `(3, 4)` and `(3, 4)` are definitely equal.
This is not true in languages like JavaScript that use reference equality on
objects.

**Note:** Equality (in the Elm sense) is not possible for certain types. For
example, the functions `(\n -> n + 1)` and `(\n -> 1 + n)` are &ldquo;the
same&rdquo; but detecting this in general is [undecidable][]. In a future
release, the compiler will detect when `(==)` is used with problematic
types and provide a helpful error message. This will require quite serious
infrastructure work that makes sense to batch with another big project, so the
stopgap is to crash as quickly as possible. Problematic types include functions
and JavaScript values like `Json.Encode.Value` which could contain functions
if passed through a port.

[undecidable]: https://en.wikipedia.org/wiki/Undecidable_problem
-}
(==) : a -> a -> Bool
(==) =
  Elm.Kernel.Utils.equal


{-| Check if values are not &ldquo;the same&rdquo;.

So `(a /= b)` is the same as `(not (a == b))`.
-}
(/=) : a -> a -> Bool
(/=) =
  Elm.Kernel.Utils.notEqual



-- COMPARISONS


{-|-}
(<) : comparable -> comparable -> Bool
(<) =
  Elm.Kernel.Utils.lt


{-|-}
(>) : comparable -> comparable -> Bool
(>) =
  Elm.Kernel.Utils.gt


{-|-}
(<=) : comparable -> comparable -> Bool
(<=) =
  Elm.Kernel.Utils.le


{-|-}
(>=) : comparable -> comparable -> Bool
(>=) =
  Elm.Kernel.Utils.ge


{-| Find the smaller of two comparables.

    min 42 12345678 == 42
    min "abc" "xyz" == "abc"
-}
min : comparable -> comparable -> comparable
min x y =
  if x < y then x else y


{-| Find the larger of two comparables.

    max 42 12345678 == 12345678
    max "abc" "xyz" == "xyz"
-}
max : comparable -> comparable -> comparable
max x y =
  if x > y then x else y


{-| Compare any two comparable values. Comparable values include `String`, `Char`,
`Int`, `Float`, `Time`, or a list or tuple containing comparable values.
These are also the only values that work as `Dict` keys or `Set` members.

    compare 3 4 == LT
    compare 4 4 == EQ
    compare 5 4 == GT
-}
compare : comparable -> comparable -> Order
compare =
  Elm.Kernel.Utils.compare


{-| Represents the relative ordering of two things.
The relations are less than, equal to, and greater than.
-}
type Order = LT | EQ | GT



-- BOOLEANS


{-| Negate a boolean value.

    not True == False
    not False == True
-}
not : Bool -> Bool
not bool =
  if bool then False else True


{-| The logical AND operator. `True` if both inputs are `True`.

    True  && True  == True
    True  && False == False
    False && True  == False
    False && False == False

**Note:** When used in the infix position, like `(left && right)`, the operator
short-circuits. This means if `left` is `False` we do not bother evaluating `right`
and just return `False` overall.
-}
(&&) : Bool -> Bool -> Bool
(&&) =
  Elm.Kernel.Basics.and


{-| The logical OR operator. `True` if one or both inputs are `True`.

    True  || True  == True
    True  || False == True
    False || True  == True
    False || False == False

**Note:** When used in the infix position, like `(left || right)`, the operator
short-circuits. This means if `left` is `True` we do not bother evaluating `right`
and just return `True` overall.
-}
(||) : Bool -> Bool -> Bool
(||) =
  Elm.Kernel.Basics.or


{-| The exclusive-or operator. `True` if exactly one input is `True`.

    xor True  True  == False
    xor True  False == True
    xor False True  == True
    xor False False == False
-}
xor : Bool -> Bool -> Bool
xor =
  Elm.Kernel.Basics.xor



-- APPEND


{-| Put two appendable things together. This includes strings, lists, and text.

    "hello" ++ "world" == "helloworld"
    [1,1,2] ++ [3,5,8] == [1,1,2,3,5,8]
-}
(++) : appendable -> appendable -> appendable
(++) =
  Elm.Kernel.Utils.append



-- FANCIER MATH


{-| Perform [modular arithmetic](http://en.wikipedia.org/wiki/Modular_arithmetic).
A common trick is to use (n mod 2) to detect even and odd numbers:

    modBy 2 0 == 0
    modBy 2 1 == 1
    modBy 2 2 == 0
    modBy 2 3 == 1

Our `modBy` function works in the typical mathematical way when you run into
negative numbers:

    List.map (modBy 4) [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
    --                 [  3,  0,  1,  2,  3,  0,  1,  2,  3,  0,  1 ]

Use [`remainderBy`](#remainderBy) for a different treatment of negative numbers.
-}
modBy : Int -> Int -> Int
modBy =
  Elm.Kernel.Basics.modBy


{-| Get the remainder after division. Here are bunch of examples of dividing by four:

    List.map (remainderBy 4) [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
    --                       [ -1,  0, -3, -2, -1,  0,  1,  2,  3,  0,  1 ]

Use [`modBy`](#modBy) for a different treatment of negative numbers.
-}
remainderBy : Int -> Int -> Int
remainderBy =
  Elm.Kernel.Basics.remainderBy


{-| Negate a number.

    negate 42 == -42
    negate -42 == 42
    negate 0 == 0
-}
negate : number -> number
negate n =
  -n


{-| Get the [absolute value][abs] of a number.

    abs 16   == 16
    abs -4   == 4
    abs -8.5 == 8.5
    abs 3.14 == 3.14

[abs]: https://en.wikipedia.org/wiki/Absolute_value
-}
abs : number -> number
abs n =
  if n < 0 then -n else n


{-| Clamps a number within a given range. With the expression
`clamp 100 200 x` the results are as follows:

    100     if x < 100
     x      if 100 <= x < 200
    200     if 200 <= x
-}
clamp : number -> number -> number -> number
clamp low high number =
  if number < low then
    low
  else if number > high then
    high
  else
    number


{-| Take the square root of a number.

    sqrt  4 == 2
    sqrt  9 == 3
    sqrt 16 == 4
    sqrt 25 == 5
-}
sqrt : Float -> Float
sqrt =
  Elm.Kernel.Basics.sqrt


{-| Calculate the logarithm of a number with a given base.

    logBase 10 100 == 2
    logBase 2 256 == 8
-}
logBase : Float -> Float -> Float
logBase base number =
  Elm.Kernel.Basics.log number / Elm.Kernel.Basics.log Elm.Kernel.Basics.e


{-| An approximation of e.
-}
e : Float
e =
  Elm.Kernel.Basics.e



-- ANGLES


{-| Convert radians to standard Elm angles (radians).
-}
radians : Float -> Float
radians t =
  t


{-| Convert degrees to standard Elm angles (radians).
-}
degrees : Float -> Float
degrees degs =
  degs * pi / 180


{-| Convert turns to standard Elm angles (radians). One turn is equal to
360&deg;.
-}
turns : Float -> Float
turns ts =
  2 * pi * ts



-- TRIGONOMETRY


{-| An approximation of pi.
-}
pi : Float
pi =
  Elm.Kernel.Basics.pi


{-|-}
cos : Float -> Float
cos =
  Elm.Kernel.Basics.cos


{-|-}
sin : Float -> Float
sin =
  Elm.Kernel.Basics.sin


{-|-}
tan : Float -> Float
tan =
  Elm.Kernel.Basics.tan


{-|-}
acos : Float -> Float
acos =
  Elm.Kernel.Basics.acos


{-|-}
asin : Float -> Float
asin =
  Elm.Kernel.Basics.asin


{-| You probably do not want to use this. It takes `(y/x)` as the
argument, so there is no way to know whether the negative signs comes from
the `y` or `x`. Thus, the resulting angle is always between &pi;/2 and -&pi;/2
(in quadrants I and IV). You probably want to use `atan2` instead.
-}
atan : Float -> Float
atan =
  Elm.Kernel.Basics.atan


{-| This helps you find the angle of a Cartesian coordinate.
You will almost certainly want to use this instead of `atan`.
So `atan2 y x` computes *atan(y/x)* but also keeps track of which
quadrant the angle should really be in. The result will be between
&pi; and -&pi;, giving you the full range of angles.
-}
atan2 : Float -> Float -> Float
atan2 =
  Elm.Kernel.Basics.atan2



-- POLAR COORDINATES


{-| Convert polar coordinates (r,&theta;) to Cartesian coordinates (x,y). -}
fromPolar : (Float,Float) -> (Float,Float)
fromPolar ( radius, theta ) =
  ( radius * cos theta, radius * sin theta )


{-| Convert Cartesian coordinates (x,y) to polar coordinates (r,&theta;). -}
toPolar : (Float,Float) -> (Float,Float)
toPolar ( x, y ) =
  ( sqrt (x * x + y * y), atan2 y x )



-- CRAZY FLOATS


{-| Determine whether a float is an undefined or unrepresentable number.
NaN stands for *not a number* and it is [a standardized part of floating point
numbers](http://en.wikipedia.org/wiki/NaN).

    isNaN (0/0)     == True
    isNaN (sqrt -1) == True
    isNaN (1/0)     == False  -- infinity is a number
    isNaN 1         == False
-}
isNaN : Float -> Bool
isNaN =
  Elm.Kernel.Basics.isNaN


{-| Determine whether a float is positive or negative infinity.

    isInfinite (0/0)     == False
    isInfinite (sqrt -1) == False
    isInfinite (1/0)     == True
    isInfinite 1         == False

Notice that NaN is not infinite! For float `n` to be finite implies that
`not (isInfinite n || isNaN n)` evaluates to `True`.
-}
isInfinite : Float -> Bool
isInfinite =
  Elm.Kernel.Basics.isInfinite



-- FUNCTION HELPERS


{-| Function composition, passing results along in the suggested direction. For
example, the following code checks if the square root of a number is odd:

    not << isEven << sqrt

You can think of this operator as equivalent to the following:

    (g << f)  ==  (\x -> g (f x))

So our example expands out to something like this:

    \n -> not (isEven (sqrt n))
-}
(<<) : (b -> c) -> (a -> b) -> (a -> c)
(<<) g f x =
  g (f x)


{-| Function composition, passing results along in the suggested direction. For
example, the following code checks if the square root of a number is odd:

    sqrt >> isEven >> not

This direction of function composition seems less pleasant than `(<<)` which
reads nicely in expressions like: `filter (not << isRegistered) students`
-}
(>>) : (a -> b) -> (b -> c) -> (a -> c)
(>>) f g x =
  g (f x)


{-| Forward function application `x |> f == f x`. This function is useful
for avoiding parentheses and writing code in a more natural way.
Consider the following code to create a pentagon:

    scale 2 (move (10,10) (filled blue (ngon 5 30)))

This can also be written as:

    ngon 5 30
      |> filled blue
      |> move (10,10)
      |> scale 2
-}
(|>) : a -> (a -> b) -> b
(|>) x f =
  f x


{-| Backward function application `f <| x == f x`. This function is useful for
avoiding parentheses. Consider the following code to create a text element:

    leftAligned (monospace (fromString "code"))

This can also be written as:

    leftAligned <| monospace <| fromString "code"
-}
(<|) : (a -> b) -> a -> b
(<|) f x =
  f x


{-| Given a value, returns exactly the same value. This is called
[the identity function](http://en.wikipedia.org/wiki/Identity_function).
-}
identity : a -> a
identity x =
  x


{-| Create a function that *always* returns the same value. Useful with
functions like `map`:

    List.map (always 0) [1,2,3,4,5] == [0,0,0,0,0]

    -- List.map (\_ -> 0) [1,2,3,4,5] == [0,0,0,0,0]
    -- always = (\x _ -> x)
-}
always : a -> b -> a
always a _ =
  a


{-| A value that can never happen! For context:

  - The boolean type `Bool` has two values: `True` and `False`
  - The unit type `()` has one value: `()`
  - The never type `Never` has no values!

You may see it in the wild in `Html Never` which means this HTML will never
produce any messages. You would need to write an event handler like
`onClick ??? : Attribute Never` but how can we fill in the question marks?!
So there cannot be any event handlers on that HTML.

You may also see this used with tasks that never fail, like `Task Never ()`.

The `Never` type is useful for restricting *arguments* to a function. Maybe my
API can only accept HTML without event handlers, so I require `Html Never` and
users can give `Html msg` and everything will go fine. Generally speaking, you
do not want `Never` in your return types though.
-}
type Never = JustOneMore Never


{-| A function that can never be called. Seems extremely pointless, but it
*can* come in handy. Imagine you have some HTML that should never produce any
messages. And say you want to use it in some other HTML that *does* produce
messages. You could say:

    import Html exposing (..)

    embedHtml : Html Never -> Html msg
    embedHtml staticStuff =
      div []
        [ text "hello"
        , Html.map never staticStuff
        ]

So the `never` function is basically telling the type system, make sure no one
ever calls me!
-}
never : Never -> a
never (JustOneMore nvr) =
  never nvr
