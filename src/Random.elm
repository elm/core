effect module Random where { command = MyCmd } exposing
  ( Generator, Seed
  , bool, int, float
  , list, pair
  , map, map2, map3, map4, map5
  , andThen
  , minInt, maxInt
  , generate
  , step, initialSeed
  )

{-| This library helps you generate pseudo-random values.

This library is all about building [`generators`](#Generator) for whatever
type of values you need. There are a bunch of primitive generators like
[`bool`](#bool) and [`int`](#int) that you can build up into fancier
generators with functions like [`list`](#list) and [`map`](#map).

It may be helpful to [read about JSON decoders][json] because they work very
similarly.

[json]: https://evancz.gitbooks.io/an-introduction-to-elm/content/interop/json.html

> *Note:* This is an implementation of the Portable Combined Generator of
L'Ecuyer for 32-bit computers. It is almost a direct translation from the
[System.Random](http://hackage.haskell.org/package/random-1.0.1.1/docs/System-Random.html)
module. It has a period of roughly 2.30584e18.

# Generators
@docs Generator

# Primitive Generators
@docs bool, int, float

# Data Structure Generators
@docs pair, list

# Custom Generators
@docs map, map2, map3, map4, map5, andThen

# Generate Values
@docs generate

# Generate Values Manually
@docs step, Seed, initialSeed

# Constants
@docs maxInt, minInt

-}

import Basics exposing (..)
import Bitwise
import List exposing ((::))
import Platform
import Platform.Cmd exposing (Cmd)
import Task exposing (Task)
import Time



-- PRIMITIVE GENERATORS


{-| Create a generator that produces boolean values. The following example
simulates a coin flip that may land heads or tails.

    type Flip = Heads | Tails

    coinFlip : Generator Flip
    coinFlip =
        map (\b -> if b then Heads else Tails) bool
-}
bool : Generator Bool
bool =
  map ((==) 1) (int 0 1)


{-| Generate 32-bit integers in a given range.

    int 0 10   -- an integer between zero and ten
    int -5 5   -- an integer between -5 and 5

    int minInt maxInt  -- an integer in the widest range feasible

This function *can* produce values outside of the range [[`minInt`](#minInt),
[`maxInt`](#maxInt)] but sufficient randomness is not guaranteed.
-}
int : Int -> Int -> Generator Int
int a b =
  Generator <| \seed0 ->
    let
      (lo,hi) =
        if a < b then (a,b) else (b,a)

      range =
        hi - lo + 1

    in
      -- fast path for power of 2
      if ((range & (range - 1)) == 0) then
          (((peel seed0 & (range - 1)) >>> 0) + lo, next seed0)
      else
        let
          threshhold =
            -- essentially: period % range
            -- define range and paste this into node if you're confused
            ((-range >>> 0) % range) >>> 0

          -- See "Explanation of the PCG algorithm" for why this is required.
          accountForBias : Seed -> ( Int, Seed )
          accountForBias seed =
            let
              x =
                peel seed

              seedN =
                next seed
            in
              if x < threshhold then
              -- in practice this recurses almost never
                accountForBias seedN
              else
                ( x % range + lo, seedN )
        in
              accountForBias seed0


{-| The maximum value for randomly generated 32-bit ints: 2147483647 -}
maxInt : Int
maxInt =
  2147483647


{-| The minimum value for randomly generated 32-bit ints: -2147483648 -}
minInt : Int
minInt =
  -2147483648


{-| Generate floats in a given range. The following example is a generator
that produces decimals between 0 and 1.

    probability : Generator Float
    probability =
        float 0 1
-}
float : Float -> Float -> Generator Float
float a b =
  Generator <| \seed0 ->
    let
      -- Get 64 bits of randomness
      seed1 =
        next seed0

      n0 =
        peel seed0

      n1 =
        peel seed1

      -- Get a uniformly distributed IEEE-754 double between 0.0 and 1.0
      hi =
        toFloat (n0 & 0x03FFFFFF) * 1.0

      lo =
        toFloat (n1 & 0x07FFFFFF) * 1.0

      val =
        -- These magic constants are 2^27 and 2^53
        ((hi * 134217728.0) + lo) / 9007199254740992.0

      -- Scale it into our range
      range =
        abs (b - a)

      scaled =
        val * range + a
    in
      ( scaled, next seed1 )


-- DATA STRUCTURES


{-| Create a pair of random values. A common use of this might be to generate
a point in a certain 2D space. Imagine we have a collage that is 400 pixels
wide and 200 pixels tall.

    randomPoint : Generator (Int,Int)
    randomPoint =
        pair (int -200 200) (int -100 100)

-}
pair : Generator a -> Generator b -> Generator (a,b)
pair genA genB =
  map2 (,) genA genB


{-| Create a list of random values.

    floatList : Generator (List Float)
    floatList =
        list 10 (float 0 1)

    intList : Generator (List Int)
    intList =
        list 5 (int 0 100)

    intPairs : Generator (List (Int, Int))
    intPairs =
        list 10 <| pair (int 0 100) (int 0 100)
-}
list : Int -> Generator a -> Generator (List a)
list n (Generator generate) =
  Generator <| \seed ->
    listHelp [] n generate seed


listHelp : List a -> Int -> (Seed -> (a,Seed)) -> Seed -> (List a, Seed)
listHelp list n generate seed =
  if n < 1 then
    (List.reverse list, seed)

  else
    let
      (value, newSeed) =
        generate seed
    in
      listHelp (value :: list) (n-1) generate newSeed



-- CUSTOM GENERATORS


{-| Transform the values produced by a generator. The following examples show
how to generate booleans and letters based on a basic integer generator.

    bool : Generator Bool
    bool =
      map ((==) 1) (int 0 1)

    lowercaseLetter : Generator Char
    lowercaseLetter =
      map (\n -> Char.fromCode (n + 97)) (int 0 25)

    uppercaseLetter : Generator Char
    uppercaseLetter =
      map (\n -> Char.fromCode (n + 65)) (int 0 25)

-}
map : (a -> b) -> Generator a -> Generator b
map func (Generator genA) =
  Generator <| \seed0 ->
    let
      (a, seed1) = genA seed0
    in
      (func a, seed1)


{-| Combine two generators.

This function is used to define things like [`pair`](#pair) where you want to
put two generators together.

    pair : Generator a -> Generator b -> Generator (a,b)
    pair genA genB =
      map2 (,) genA genB

-}
map2 : (a -> b -> c) -> Generator a -> Generator b -> Generator c
map2 func (Generator genA) (Generator genB) =
  Generator <| \seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
    in
      (func a b, seed2)


{-| Combine three generators. This could be used to produce random colors.

    import Color

    rgb : Generator Color.Color
    rgb =
      map3 Color.rgb (int 0 255) (int 0 255) (int 0 255)

    hsl : Generator Color.Color
    hsl =
      map3 Color.hsl (map degrees (int 0 360)) (float 0 1) (float 0 1)
-}
map3 : (a -> b -> c -> d) -> Generator a -> Generator b -> Generator c -> Generator d
map3 func (Generator genA) (Generator genB) (Generator genC) =
  Generator <| \seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
    in
      (func a b c, seed3)


{-| Combine four generators.
-}
map4 : (a -> b -> c -> d -> e) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e
map4 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) =
  Generator <| \seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
      (d, seed4) = genD seed3
    in
      (func a b c d, seed4)


{-| Combine five generators.
-}
map5 : (a -> b -> c -> d -> e -> f) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e -> Generator f
map5 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) (Generator genE) =
  Generator <| \seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
      (d, seed4) = genD seed3
      (e, seed5) = genE seed4
    in
      (func a b c d e, seed5)


{-| Chain random operations, threading through the seed. In the following
example, we will generate a random letter by putting together uppercase and
lowercase letters.

    letter : Generator Char
    letter =
      bool `andThen` \b ->
        if b then uppercaseLetter else lowercaseLetter

    -- bool : Generator Bool
    -- uppercaseLetter : Generator Char
    -- lowercaseLetter : Generator Char
-}
andThen : Generator a -> (a -> Generator b) -> Generator b
andThen (Generator generate) callback =
  Generator <| \seed ->
    let
      (result, newSeed) =
        generate seed

      (Generator genB) =
        callback result
    in
      genB newSeed



-- IMPLEMENTATION

{- Explanation of the PCG algorithm

    PCG uses 64 bits of state. There is one function (next) to derive the next
    state and another to obtain 32 psuedo-random bits from the current state.

    Getting the next state is easy: multiply by a magic factor, and then add an
    increment. In this implementation, we're using a constant, magic increment.
    BUT: you can use any odd 64-bit integer you like, keep it in the seed (so
    128 bits of state), and pass it on to the next seed unchanged. (You can
    generate the increment from the RNG itself if you have to.) If two seeds
    have different increments, their random numbers from the two seeds will
    never match up; they are completely independent. This is very helpful for
    isolated components or multithreading.

    Transforming a seed into a random number is more complicated, but
    essentially you use the "most random" bits to pick some way of scrambling
    the remaining bits. Once you have 32 random bits, you have to turn it into a
    number. For integers, we first check if the range is a power of two. If it
    is, we can mask part of the value and be done. If not, we need to account
    for bias.

    Let's say you want a random number between 1 and 7 but I can only generate
    random numbers between 1 and 32. If I modulus by result by 7, I'm biased,
    because there are more random numbers that lead to 1 than 7. So instead, I
    check to see if my random number exceeds 28 (the largest multiple of 7 less
    than 32). If it does, I reroll, otherwise I mod by seven. This sounds
    wateful, except that instead of 32 it's 2^32, so in practice it's hard to
    notice. So that's how we get random ints. There's another process from
    floats, but I don't understand it very well.

    A note on bitwise ops: x >>> 0 is used throughout this file to force values
    into 32-bit integers. Don't let it freak you out.
-}


(&) =
    Bitwise.and


-- Beware that we're shadowed function composition
(<<) =
    Bitwise.shiftLeft


(>>>) =
    Bitwise.shiftRightLogical


-- A private type used to represent 64-bit integers.
type Int64
    = Int64 Int Int


{-| A `Seed` is the source of randomness in this whole system. Whenever
you want to use a generator, you need to pair it with a seed.
-}
type Seed =
  Seed Int64


magicFactor : Int64
magicFactor =
    Int64 0x5851F42D 0x4C957F2D


magicIncrement : Int64
magicIncrement =
    Int64 0x14057B7E 0xF767814F


-- A private function to derive the next seed
next : Seed -> Seed
next (Seed state0) =
    let
        state1 =
            mul64 state0 magicFactor

        state2 =
            add64 state1 magicIncrement
    in
        Seed state2


-- A private function to obtain a psuedorandom 32-bit integer
peel : Seed -> Int
peel (Seed (Int64 oldHi oldLo)) =
    let
        -- get least sig. 32 bits of ((oldstate >> 18) ^ oldstate) >> 27
        xsHi =
            oldHi >>> 18

        xsLo =
            ((oldLo >>> 18) `Bitwise.or` (oldHi << 14)) >>> 0

        xsHi' =
            (xsHi `Bitwise.xor` oldHi) >>> 0

        xsLo' =
            (xsLo `Bitwise.xor` oldLo) >>> 0

        xorshifted =
            ((xsLo' >>> 27) `Bitwise.or` (xsHi' << 5)) >>> 0

        -- rotate xorshifted right a random amount, based on the most sig. 5 bits
        -- bits of the old state.
        rot =
            oldHi >>> 27

        rot2 =
            ((-rot >>> 0) & 31) >>> 0
    in
        ((xorshifted >>> rot) `Bitwise.or` (xorshifted << rot2)) >>> 0


{-| A `Generator` is like a recipe for generating certain random values. So a
`Generator Int` describes how to generate integers and a `Generator String`
describes how to generate strings.

To actually *run* a generator and produce the random values, you need to use
functions like [`generate`](#generate) and [`initialSeed`](#initialSeed).
-}
type Generator a =
    Generator (Seed -> (a, Seed))


{-| Generate a random value as specified by a given `Generator`.

In the following example, we are trying to generate a number between 0 and 100
with the `int 0 100` generator. Each time we call `step` we need to provide a
seed. This will produce a random number and a *new* seed to use if we want to
run other generators later.

So here it is done right, where we get a new seed from each `step` call and
thread that through.

    seed0 = initialSeed 31415

    -- step (int 0 100) seed0 ==> (42, seed1)
    -- step (int 0 100) seed1 ==> (31, seed2)
    -- step (int 0 100) seed2 ==> (99, seed3)

Notice that we use different seeds on each line. This is important! If you use
the same seed, you get the same results.

    -- step (int 0 100) seed0 ==> (42, seed1)
    -- step (int 0 100) seed0 ==> (42, seed1)
    -- step (int 0 100) seed0 ==> (42, seed1)
-}
step : Generator a -> Seed -> (a, Seed)
step (Generator generator) seed =
  generator seed


{-| Create a &ldquo;seed&rdquo; of randomness which makes it possible to
generate random values. If you use the same seed many times, it will result
in the same thing every time! A good way to get an unexpected seed is to use
the current time.
-}
initialSeed : Int -> Seed
initialSeed n =
    let
      intermediateState =
        -- The least significant 32 bits are zeroes. It works, but it's not ideal.
        add64 magicIncrement (Int64 (n >>> 0) 0)
    in
      next (Seed intermediateState)


-- MANAGER


{-| Create a command that will generate random values.

Read more about how to use this in your programs in [The Elm Architecture
tutorial][arch] which has a section specifically [about random values][rand].

[arch]: https://evancz.gitbooks.io/an-introduction-to-elm/content/architecture/index.html
[rand]: https://evancz.gitbooks.io/an-introduction-to-elm/content/architecture/effects/random.html
-}
generate : (a -> msg) -> Generator a -> Cmd msg
generate tagger generator =
  command (Generate (map tagger generator))


type MyCmd msg = Generate (Generator msg)


cmdMap : (a -> b) -> MyCmd a -> MyCmd b
cmdMap func (Generate generator) =
  Generate (map func generator)


init : Task Never Seed
init =
  Time.now `Task.andThen` \t ->
    Task.succeed (initialSeed (round t))


onEffects : Platform.Router msg Never -> List (MyCmd msg) -> Seed -> Task Never Seed
onEffects router commands seed =
  case commands of
    [] ->
      Task.succeed seed

    Generate generator :: rest ->
      let
        (value, newSeed) =
          step generator seed
      in
        Platform.sendToApp router value
          `Task.andThen` \_ ->

        onEffects router rest newSeed


onSelfMsg : Platform.Router msg Never -> Never -> Seed -> Task Never Seed
onSelfMsg _ _ seed =
  Task.succeed seed


-- 64-bit Arithmetic helpers


mul32 : Int -> Int -> Int
mul32 a b =
    let
        ah =
            (a >>> 16) & 0xFFFF

        al =
            a & 0xFFFF

        bh =
            (b >>> 16) & 0xFFFF

        bl =
            b & 0xFFFF
    in
        (al * bl) + (((ah * bl + al * bh) << 16) >>> 0) |> Bitwise.or 0


mul64 : Int64 -> Int64 -> Int64
mul64 (Int64 aHi aLo) (Int64 bHi bLo) =
    let
        -- this is taken from a mutable implementation, so there are a lot of primes.
        c1 =
            (aLo >>> 16) * (bLo & 0xFFFF) >>> 0

        c0 =
            (aLo & 0xFFFF) * (bLo >>> 16) >>> 0

        lo =
            ((aLo & 0xFFFF) * (bLo & 0xFFFF)) >>> 0

        hi =
            ((aLo >>> 16) * (bLo >>> 16)) + ((c0 >>> 16) + (c1 >>> 16)) >>> 0

        c0' =
            (c0 << 16) >>> 0

        lo' =
            (lo + c0') >>> 0

        hi' =
            if (lo' >>> 0) < (c0' >>> 0) then
                (hi + 1) >>> 0
            else
                hi

        c1' =
            (c1 << 16) >>> 0

        lo'' =
            (lo' + c1') >>> 0

        hi'' =
            if (lo'' >>> 0) < (c1' >>> 0) then
                (hi' + 1) >>> 0
            else
                hi'

        hi''' =
            (hi'' + mul32 aLo bHi) >>> 0

        hi'''' =
            (hi''' + mul32 aHi bLo) >>> 0
    in
        Int64 hi'''' lo''


add64 : Int64 -> Int64 -> Int64
add64 (Int64 aHi aLo) (Int64 bHi bLo) =
    let
        hi =
            (aHi + bHi) >>> 0

        lo =
            (aLo + bLo) >>> 0

        hi' =
            if ((lo >>> 0) < (aLo >>> 0)) then
                (hi + 1) `Bitwise.or` 0
            else
                hi
    in
        Int64 hi' lo
