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

This is an implementation of [Permuted Congruential Generators][pcg]
by M. E. O'Neil. It is not cryptographically secure.

[pcg]: http://www.pcg-random.org/


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
import Tuple



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
    Generator
        (\seed0 ->
            let
                ( lo, hi ) =
                    if a < b then
                        ( a, b )
                    else
                        ( b, a )

                range =
                    hi - lo + 1
            in
                -- fast path for power of 2
                if (Bitwise.and (range - 1) range) == 0 then
                    ( (Bitwise.shiftRightZfBy 0 (Bitwise.and (range - 1) (peel seed0))) + lo, next seed0 )
                else
                    let
                        threshhold =
                            -- essentially: period % max
                            Bitwise.shiftRightZfBy 0 (remainderBy range (Bitwise.shiftRightZfBy 0 -range))

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
                                    ( remainderBy range x + lo, seedN )
                    in
                        accountForBias seed0
        )


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
    Generator (\seed0 ->
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
                toFloat (Bitwise.and 0x03FFFFFF n0) * 1.0

            lo =
                toFloat (Bitwise.and 0x07FFFFFF n1) * 1.0

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
        )


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
  Generator (\seed ->
    listHelp [] n generate seed
  )


listHelp : List a -> Int -> (Seed -> (a,Seed)) -> Seed -> (List a, Seed)
listHelp list n generate seed =
  if n < 1 then
    (list, seed)

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
  Generator (\seed0 ->
    let
      (a, seed1) = genA seed0
    in
      (func a, seed1)
  )


{-| Combine two generators.

This function is used to define things like [`pair`](#pair) where you want to
put two generators together.

    pair : Generator a -> Generator b -> Generator (a,b)
    pair genA genB =
      map2 (,) genA genB

-}
map2 : (a -> b -> c) -> Generator a -> Generator b -> Generator c
map2 func (Generator genA) (Generator genB) =
  Generator (\seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
    in
      (func a b, seed2)
  )


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
  Generator (\seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
    in
      (func a b c, seed3)
  )


{-| Combine four generators.
-}
map4 : (a -> b -> c -> d -> e) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e
map4 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) =
  Generator (\seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
      (d, seed4) = genD seed3
    in
      (func a b c d, seed4)
  )


{-| Combine five generators.
-}
map5 : (a -> b -> c -> d -> e -> f) -> Generator a -> Generator b -> Generator c -> Generator d -> Generator e -> Generator f
map5 func (Generator genA) (Generator genB) (Generator genC) (Generator genD) (Generator genE) =
  Generator (\seed0 ->
    let
      (a, seed1) = genA seed0
      (b, seed2) = genB seed1
      (c, seed3) = genC seed2
      (d, seed4) = genD seed3
      (e, seed5) = genE seed4
    in
      (func a b c d e, seed5)
  )


{-| Chain random operations, threading through the seed. In the following
example, we will generate a random letter by putting together uppercase and
lowercase letters.

    letter : Generator Char
    letter =
      bool
        |> andThen upperOrLower

    upperOrLower : Bool -> Generator Char
    upperOrLower b =
      if b then uppercaseLetter else lowercaseLetter

    -- bool : Generator Bool
    -- uppercaseLetter : Generator Char
    -- lowercaseLetter : Generator Char
-}
andThen : (a -> Generator b) -> Generator a -> Generator b
andThen callback (Generator generate) =
  Generator (\seed ->
    let
      (result, newSeed) =
        generate seed

      (Generator genB) =
        callback result
    in
      genB newSeed
  )



-- IMPLEMENTATION

{- Explanation of the PCG algorithm

    This is a special variation (dubbed RXS-M-SH) that produces 32
    bits of output by keeping 32 bits of state. There is one function
    (next) to derive the following state and another (peel) to obtain 32
    psuedo-random bits from the current state.

    Getting the next state is easy: multiply by a magic factor, and then add an
    increment. In this implementation, we're using a hard-coded, magic
    increment. This is a simplification from the 3rd party library, which
    carries the increment in the seed. If two seeds have different increments,
    their random numbers from the two seeds will never match up; they are
    completely independent. This is very helpful for isolated components or
    multithreading, and elm-test relies on this feature.

    Transforming a seed into 32 random bits is more complicated, but
    essentially you use the "most random" bits to pick some way of scrambling
    the remaining bits. Beyond that, see section 6.3.4 of the [paper].

    [paper](http://www.pcg-random.org/paper.html)

    Once we have 32 random bits, we have to turn it into a number. For integers,
    we first check if the range is a power of two. If it is, we can mask part of
    the value and be done. If not, we need to account for bias.

    Let's say you want a random number between 1 and 7 but I can only generate
    random numbers between 1 and 32. If I modulus by result by 7, I'm biased,
    because there are more random numbers that lead to 1 than 7. So instead, I
    check to see if my random number exceeds 28 (the largest multiple of 7 less
    than 32). If it does, I reroll, otherwise I mod by seven. This sounds
    wateful, except that instead of 32 it's 2^32, so in practice it's hard to
    notice. So that's how we get random ints. There's another process from
    floats, but I don't understand it very well.
-}


{-| A `Seed` is the source of randomness in the whole system. It hides the
current state of the random number generator.

Generators, not seeds, are the primary data structure for generating random
values. Generators are much easier to chain and combine than functions that take
and return seeds. Creating and managing seeds should happen "high up" in your
program.
-}
type Seed
    = Seed Int

-- step the RNG to produce the next seed
next : Seed -> Seed
next (Seed state0) =
    -- The magic constants are from Numerical Recipes and are inlined for perf.
    Seed (Bitwise.shiftRightZfBy 0 ((state0 * 1664525) + 1013904223))


-- obtain a psuedorandom 32-bit integer from a seed
peel : Seed -> Int
peel (Seed state) =
    -- This is the RXS-M-SH version of PCG, see section 6.3.4 of the paper
    -- and line 184 of pcg_variants.h in the 0.94 (non-minimal) C implementation,
    -- the latter of which is the source of the magic constant.
    let
        word =
            (Bitwise.xor state (Bitwise.shiftRightZfBy ((Bitwise.shiftRightZfBy 28 state) + 4) state)) * 277803737
    in
        Bitwise.shiftRightZfBy 0 (Bitwise.xor (Bitwise.shiftRightZfBy 22 word) word)


{-| A `Generator` is like a recipe for generating certain random values. So a
`Generator Int` describes how to generate integers and a `Generator String`
describes how to generate strings.

To actually *run* a generator and produce the random values, you need to use
either [`generate`](#generate), or [`step`](#step) and [`initialSeed`](#initialSeed).
-}
type Generator a =
    Generator (Seed -> (a, Seed))


{-| Generate a random value as specified by a given `Generator`, using a `Seed`
and returning a new one.

In the following example, we are trying to generate numbers between 0 and 100
with the `int 0 100` generator. Each time we call `step` we need to provide
a seed. This will produce a random number and a *new* seed to use if we want to
run other generators later.

    (x, seed1) = step (int 0 100) seed0
    (y, seed2) = step (int 0 100) seed1
    (z, seed3) = step (int 0 100) seed2
    [x, y, z] -- [85, 0, 38]

Notice that we use different seeds on each line. This is important! If you reuse
the same seed, you get the same results.

    (x, _) = step (int 0 100) seed0
    (y, _) = step (int 0 100) seed0
    (z, _) = step (int 0 100) seed0
    [x,y,z] -- [85, 85, 85]

As you can see, threading seeds through many calls to `step` is tedious and
error-prone. That's why this library includes many functions to build more
complicated generators, allowing you to call `step` only a small number of
times.

Our example is best written as:

    (values, seed1) = step (list 3 <| int 0 100) seed0
    values -- [85, 0, 38]

-}
step : Generator a -> Seed -> (a, Seed)
step (Generator generator) seed =
  generator seed


{-| Initialize the state of the random number generator. The input should be
a randomly chosen 32-bit integer. You can generate and copy random integers to
create a reproducible psuedo-random generator.

    $ node
    > Math.floor(Math.random()*0xFFFFFFFF)
    227852860

    -- Elm
    seed0 : Seed
    seed0 = initialSeed 227852860

Alternatively, you can generate the random integers on page load and pass them
through a port. The program will be different every time.

    -- Elm
    port randomSeed : Int

    seed0 : Seed
    seed0 = initialSeed randomSeed

    -- JS
    Elm.ModuleName.fullscreen(
      { randomSeed: Math.floor(Math.random()*0xFFFFFFFF) })

Either way, you should initialize a random seed only once. After that, whenever
you use a seed, you'll get another one back.
-}
initialSeed : Int -> Seed
initialSeed x =
    let
        (Seed state1) =
            next (Seed 0)

        state2 =
            Bitwise.shiftRightZfBy 0 (state1 + x)
    in
        next (Seed state2)


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
    Task.andThen (\t -> Task.succeed (initialSeed (round t))) Time.now


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
          Task.andThen
            (\_ -> onEffects router rest newSeed)
            (Platform.sendToApp router value)


onSelfMsg : Platform.Router msg Never -> Never -> Seed -> Task Never Seed
onSelfMsg _ _ seed =
  Task.succeed seed
