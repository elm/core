module Basics exposing
  ( (==), (/=)
  , (<), (>), (<=), (>=), max, min, Order (..), compare
  , not, (&&), (||), xor
  , (+), (-), (*), (/), (^), (//), rem, (%), negate, abs, sqrt, clamp, logBase, e
  , pi, cos, sin, tan, acos, asin, atan, atan2
  , round, floor, ceiling, truncate, toFloat
  , degrees, radians, turns
  , toPolar, fromPolar
  , isNaN, isInfinite
  , toString, (++)
  , identity, always, (<|), (|>), (<<), (>>), flip, curry, uncurry, Never, never
  )

{-| Tons of useful functions that get imported by default.

# Equality
@docs (==), (/=)

# Comparison

These functions only work on `comparable` types. This includes numbers,
characters, strings, lists of comparable things, and tuples of comparable
things. Note that tuples with 7 or more elements are not comparable; why
are your tuples so big?

@docs (<), (>), (<=), (>=), max, min, Order, compare

# Booleans
@docs not, (&&), (||), xor

# Mathematics
@docs (+), (-), (*), (/), (^), (//), rem, (%), negate, abs, sqrt, clamp, logBase, e

# Trigonometry
@docs pi, cos, sin, tan, acos, asin, atan, atan2

# Number Conversions
@docs round, floor, ceiling, truncate, toFloat

# Angle Conversions
All angle conversions result in &ldquo;standard Elm angles&rdquo;
which happen to be radians.

@docs degrees, radians, turns

# Polar Coordinates
@docs toPolar, fromPolar

# Floating Point Checks
@docs isNaN, isInfinite

# Strings and Lists
@docs toString, (++)

# Higher-Order Helpers
@docs identity, always, (<|), (|>), (<<), (>>), flip, curry, uncurry, Never, never

-}

import Native.Basics
import Native.Utils


{-| Convert radians to standard Elm angles (radians). -}
radians : Float -> Float
radians t =
  t


{-| Convert degrees to standard Elm angles (radians). -}
degrees : Float -> Float
degrees =
  Native.Basics.degrees


{-| Convert turns to standard Elm angles (radians).
One turn is equal to 360&deg;.
-}
turns : Float -> Float
turns =
  Native.Basics.turns


{-| Convert polar coordinates (r,&theta;) to Cartesian coordinates (x,y). -}
fromPolar : (Float,Float) -> (Float,Float)
fromPolar =
  Native.Basics.fromPolar


{-| Convert Cartesian coordinates (x,y) to polar coordinates (r,&theta;). -}
toPolar : (Float,Float) -> (Float,Float)
toPolar =
  Native.Basics.toPolar


{-|-}
(+) : number -> number -> number
(+) =
  Native.Basics.add


{-|-}
(-) : number -> number -> number
(-) =
  Native.Basics.sub


{-|-}
(*) : number -> number -> number
(*) =
  Native.Basics.mul


{-| Floating point division. -}
(/) : Float -> Float -> Float
(/) =
  Native.Basics.floatDiv


infixl 6 +
infixl 6 -
infixl 7 *
infixl 7 /
infixr 8 ^

infixl 7 //
infixl 7 %


{-| Integer division. The remainder is discarded. -}
(//) : Int -> Int -> Int
(//) =
  Native.Basics.div


{-| Find the remainder after dividing one number by another.

    rem 11 4 == 3
    rem 12 4 == 0
    rem 13 4 == 1
    rem -1 4 == -1
-}
rem : Int -> Int -> Int
rem =
  Native.Basics.rem


{-| Perform [modular arithmetic](http://en.wikipedia.org/wiki/Modular_arithmetic).

     7 % 2 == 1
    -1 % 4 == 3
-}
(%) : Int -> Int -> Int
(%) =
  Native.Basics.mod


{-| Exponentiation

    3^2 == 9
-}
(^) : number -> number -> number
(^) =
  Native.Basics.exp


{-|-}
cos : Float -> Float
cos =
  Native.Basics.cos


{-|-}
sin : Float -> Float
sin =
  Native.Basics.sin


{-|-}
tan : Float -> Float
tan =
  Native.Basics.tan


{-|-}
acos : Float -> Float
acos =
  Native.Basics.acos


{-|-}
asin : Float -> Float
asin =
  Native.Basics.asin


{-| You probably do not want to use this. It takes `(y/x)` as the
argument, so there is no way to know whether the negative signs comes from
the `y` or `x`. Thus, the resulting angle is always between &pi;/2 and -&pi;/2
(in quadrants I and IV). You probably want to use `atan2` instead.
-}
atan : Float -> Float
atan =
  Native.Basics.atan


{-| This helps you find the angle of a Cartesian coordinate.
You will almost certainly want to use this instead of `atan`.
So `atan2 y x` computes *atan(y/x)* but also keeps track of which
quadrant the angle should really be in. The result will be between
&pi; and -&pi;, giving you the full range of angles.
-}
atan2 : Float -> Float -> Float
atan2 =
  Native.Basics.atan2


{-| Take the square root of a number. -}
sqrt : Float -> Float
sqrt =
  Native.Basics.sqrt


{-| Negate a number.

    negate 42 == -42
    negate -42 == 42
    negate 0 == 0
-}
negate : number -> number
negate =
  Native.Basics.negate


{-| Take the absolute value of a number. -}
abs : number -> number
abs =
  Native.Basics.abs


{-| Calculate the logarithm of a number with a given base.

    logBase 10 100 == 2
    logBase 2 256 == 8
-}
logBase : Float -> Float -> Float
logBase =
  Native.Basics.logBase


{-| Clamps a number within a given range. With the expression
`clamp 100 200 x` the results are as follows:

    100     if x < 100
     x      if 100 <= x < 200
    200     if 200 <= x
-}
clamp : number -> number -> number -> number
clamp =
  Native.Basics.clamp


{-| An approximation of pi. -}
pi : Float
pi =
  Native.Basics.pi


{-| An approximation of e. -}
e : Float
e =
  Native.Basics.e


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
  Native.Basics.eq


{-| Check if values are not &ldquo;the same&rdquo;.

So `(a /= b)` is the same as `(not (a == b))`.
-}
(/=) : a -> a -> Bool
(/=) =
  Native.Basics.neq


{-|-}
(<) : comparable -> comparable -> Bool
(<) =
  Native.Basics.lt


{-|-}
(>) : comparable -> comparable -> Bool
(>) =
  Native.Basics.gt


{-|-}
(<=) : comparable -> comparable -> Bool
(<=) =
  Native.Basics.le


{-|-}
(>=) : comparable -> comparable -> Bool
(>=) =
  Native.Basics.ge


infix 4 ==
infix 4 /=
infix 4 <
infix 4 >
infix 4 <=
infix 4 >=


{-| Compare any two comparable values. Comparable values include `String`, `Char`,
`Int`, `Float`, `Time`, or a list or tuple containing comparable values.
These are also the only values that work as `Dict` keys or `Set` members.
-}
compare : comparable -> comparable -> Order
compare =
  Native.Basics.compare


{-| Represents the relative ordering of two things.
The relations are less than, equal to, and greater than.
-}
type Order = LT | EQ | GT


{-| Find the smaller of two comparables. -}
min : comparable -> comparable -> comparable
min =
  Native.Basics.min


{-| Find the larger of two comparables. -}
max : comparable -> comparable -> comparable
max =
  Native.Basics.max


{-| The logical AND operator. `True` if both inputs are `True`.

**Note:** When used in the infix position, like `(left && right)`, the operator
short-circuits. This means if `left` is `False` we do not bother evaluating `right`
and just return `False` overall.
-}
(&&) : Bool -> Bool -> Bool
(&&) =
  Native.Basics.and


{-| The logical OR operator. `True` if one or both inputs are `True`.

**Note:** When used in the infix position, like `(left || right)`, the operator
short-circuits. This means if `left` is `True` we do not bother evaluating `right`
and just return `True` overall.
-}
(||) : Bool -> Bool -> Bool
(||) =
  Native.Basics.or


infixr 3 &&
infixr 2 ||


{-| The exclusive-or operator. `True` if exactly one input is `True`. -}
xor : Bool -> Bool -> Bool
xor =
  Native.Basics.xor


{-| Negate a boolean value.

    not True == False
    not False == True
-}
not : Bool -> Bool
not =
  Native.Basics.not


-- Conversions

{-| Round a number to the nearest integer. -}
round : Float -> Int
round =
  Native.Basics.round


{-| Truncate a number, rounding towards zero. -}
truncate : Float -> Int
truncate =
  Native.Basics.truncate


{-| Floor function, rounding down. -}
floor : Float -> Int
floor =
  Native.Basics.floor


{-| Ceiling function, rounding up. -}
ceiling : Float -> Int
ceiling =
  Native.Basics.ceiling


{-| Convert an integer into a float. -}
toFloat : Int -> Float
toFloat =
  Native.Basics.toFloat


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
  Native.Basics.isNaN


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
  Native.Basics.isInfinite


{-| Turn any kind of value into a string. When you view the resulting string
with `Text.fromString` it should look just like the value it came from.

    toString 42 == "42"
    toString [1,2] == "[1,2]"
    toString "he said, \"hi\"" == "\"he said, \\\"hi\\\"\""
-}
toString : a -> String
toString =
  Native.Utils.toString


{-| Put two appendable things together. This includes strings, lists, and text.

    "hello" ++ "world" == "helloworld"
    [1,1,2] ++ [3,5,8] == [1,1,2,3,5,8]
-}
(++) : appendable -> appendable -> appendable
(++) =
  Native.Utils.append


infixr 5 ++


-- Function Helpers

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


infixr 9 <<
infixl 9 >>
infixr 0 <|
infixl 0 |>


{-| Given a value, returns exactly the same value. This is called
[the identity function](http://en.wikipedia.org/wiki/Identity_function).
-}
identity : a -> a
identity x =
  x


{-| Create a [constant function](http://en.wikipedia.org/wiki/Constant_function),
a function that *always* returns the same value regardless of what input you give.
It is defined as:

    always a b = a

It totally ignores the second argument, so `always 42` is a function that always
returns 42. When you are dealing with higher-order functions, this comes in
handy more often than you might expect. For example, creating a zeroed out list
of length ten would be:

    map (always 0) [0..9]
-}
always : a -> b -> a
always a _ =
  a


{-| Flip the order of the first two arguments to a function. -}
flip : (a -> b -> c) -> (b -> a -> c)
flip f b a =
  f a b


{-| Change how arguments are passed to a function.
This splits paired arguments into two separate arguments.
-}
curry : ((a,b) -> c) -> a -> b -> c
curry f a b =
  f (a,b)


{-| Change how arguments are passed to a function.
This combines two arguments into a single pair.
-}
uncurry : (a -> b -> c) -> (a,b) -> c
uncurry f (a,b) =
  f a b


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
