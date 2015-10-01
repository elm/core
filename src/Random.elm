module Random
    ( Generator, Seed
    , bool, int, float
    , list, pair
    , map, andThen
    , minInt, maxInt
    , generate, initialSeed
    , customGenerator
    )
  where

{-| This library helps you generate pseudo-random values.

The general pattern is to define a `Generator` which can produce certain kinds
of random values. You actually produce random values by feeding a fresh `Seed`
to your `Generator`.

Since you need a fresh `Seed` to produce more random values, you should
probably store a `Seed` in your application's state. This will allow you to
keep updating it as you generate random values and fresh seeds.

The following example models a bunch of bad guys that randomly appear. The
`possiblyAddBadGuy` function uses the random seed to see if we should add a bad
guy, and if so, it places a bad guy at a randomly generated point.

    type alias Model =
        { badGuys : List (Float,Float)
        , seed : Seed
        }

    possiblyAddBadGuy : Model -> Model
    possiblyAddBadGuy model =
      let
        (addProbability, seed') =
          generate (float 0 1) model.seed
      in
        if addProbability < 0.9 then
          { model | seed = seed' }
        else
          let
            (position, seed'') =
              generate (pair (float 0 100) (float 0 100)) seed'
          in
            { model |
                badGuys = position :: model.badGuys,
                seed = seed''
            }

Details: This is an implementation of the Portable Combined Generator of
L'Ecuyer for 32-bit computers. It is almost a direct translation from the
[System.Random](http://hackage.haskell.org/package/random-1.0.1.1/docs/System-Random.html)
module. It has a period of roughly 2.30584e18.

# Generators
@docs Generator, bool, int, float, pair, list, map, andThen

# Running a Generator
@docs generate, Seed, initialSeed

# Constants
@docs maxInt, minInt

# Custom Generators
@docs customGenerator

-}

import Basics exposing (..)
import List exposing ((::))


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
  Generator <| \(Seed seed) ->
    let
      (lo,hi) =
        if a < b then (a,b) else (b,a)

      k = hi - lo + 1
      -- 2^31 - 87
      base = 2147483561
      n = iLogBase base k

      f n acc state =
        case n of
          0 -> (acc, state)
          _ ->
            let
              (x, state') = seed.next state
            in
              f (n - 1) (x + acc * base) state'

      (v, state') =
        f n 1 seed.state
    in
      ( lo + v % k
      , Seed { seed | state = state' }
      )


iLogBase : Int -> Int -> Int
iLogBase b i =
  if i < b then
    1
  else
    1 + iLogBase b (i // b)


{-| The maximum value for randomly generated 32-bit ints. -}
maxInt : Int
maxInt =
  2147483647


{-| The minimum value for randomly generated 32-bit ints. -}
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
  Generator <| \seed ->
    let
      (lo, hi) =
        if a < b then (a,b) else (b,a)

      (number, seed') =
        generate (int minInt maxInt) seed

      negativeOneToOne =
        toFloat number / toFloat (maxInt - minInt)

      scaled =
        (lo+hi)/2 + ((hi-lo) * negativeOneToOne)
    in
      (scaled, seed')


-- DATA STRUCTURES

{-| Create a pair of random values. A common use of this might be to generate
a point in a certain 2D space. Imagine we have a collage that is 400 pixels
wide and 200 pixels tall.

    randomPoint : Generator (Int,Int)
    randomPoint =
        pair (int -200 200) (int -100 100)

-}
pair : Generator a -> Generator b -> Generator (a,b)
pair (Generator genLeft) (Generator genRight) =
  Generator <| \seed ->
    let
      (left, seed') =
        genLeft seed

      (right, seed'') =
        genRight seed'
    in
      ((left,right), seed'')


{-| Create a list of random values.

    floatList : Generator (List Float)
    floatList =
        list 10 (float 0 1)

    intList : Generator (List Int)
    intList =
        list 5 (int 0 100)

    intPairs : Generator (List (Int, Int))
    intPairs =
        list 10 (pair int int)
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
      (value, seed') =
        generate seed
    in
      listHelp (value :: list) (n-1) generate seed'


{-| Map a function over the value of an existing generator.

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
map f (Generator generate) =
  Generator <| \seed ->
    let
      (x, seed') =
        generate seed
    in
      (f x, seed')


{-| Chain random operations, threading through the seed. In the following
example, we will generate a random letter by putting together uppercase and
lowercase letters.

    randomLetter : Generator Char
    randomLetter =
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
      (result, seed') =
        generate seed

      (Generator generateB) =
        callback result
    in
      generateB seed'


{-| Create a custom generator. You provide a function that takes a seed, and
returns a random value and a new seed. You can use this to create custom
generators not covered by the basic functions in this library.

    pairOf : Generator a -> Generator (a,a)
    pairOf generator =
      customGenerator <| \seed ->
        let (left , seed' ) = generate generator seed
            (right, seed'') = generate generator seed'
        in
            ((left,right), seed'')

-}
customGenerator : (Seed -> (a, Seed)) -> Generator a
customGenerator generate =
  Generator generate


{-| A `Generator` is a value that can generate random values. So a
(`Generator Int`) will generate integers and a (`Generator String`) will
generate strings.
-}
type Generator a =
    Generator (Seed -> (a, Seed))

type State = State Int Int


{-| A `Seed` helps you generate random values. Think of this as a "seed of
randomness" that you can use along with a `Generator`.
-}
type Seed = Seed
    { state : State
    , next  : State -> (Int, State)
    , split : State -> (State, State)
    , range : State -> (Int,Int)
    }


{-| Run a random value generator with a given seed. It will give you back a
random value and a new seed.

    seed0 = initialSeed 31415

    -- generate (int 0 100) seed0 ==> (42, seed1)
    -- generate (int 0 100) seed1 ==> (31, seed2)
    -- generate (int 0 100) seed2 ==> (99, seed3)

Notice that we use different seeds on each line. This is important! If you use
the same seed, you get the same results.

    -- generate (int 0 100) seed0 ==> (42, seed1)
    -- generate (int 0 100) seed0 ==> (42, seed1)
    -- generate (int 0 100) seed0 ==> (42, seed1)
-}
generate : Generator a -> Seed -> (a, Seed)
generate (Generator generator) seed =
    generator seed


{-| Create a &ldquo;seed&rdquo; of randomness which makes it possible to
generate random values. If you use the same seed many times, it will result
in the same thing every time! A good way to get an unexpected seed is to use
the current time.
-}
initialSeed : Int -> Seed
initialSeed n =
    Seed { state = initState n, next = next, split = split, range = range }


{-| Produce the initial generator state. Distinct arguments should be likely
to produce distinct generator states.
-}
initState : Int -> State
initState s' =
  let
    s = max s' -s'
    q  = s // (magicNum6-1)
    s1 = s %  (magicNum6-1)
    s2 = q %  (magicNum7-1)
  in
    State (s1+1) (s2+1)


magicNum0 = 40014
magicNum1 = 53668
magicNum2 = 12211
magicNum3 = 52774
magicNum4 = 40692
magicNum5 = 3791
magicNum6 = 2147483563
magicNum7 = 2137383399
magicNum8 = 2147483562


next : State -> (Int, State)
next (State s1 s2) =
  -- Div always rounds down and so random numbers are biased
  -- ideally we would use division that rounds towards zero so
  -- that in the negative case it rounds up and in the positive case
  -- it rounds down. Thus half the time it rounds up and half the time it
  -- rounds down
  let
    k = s1 // magicNum1
    s1' = magicNum0 * (s1 - k * magicNum1) - k * magicNum2
    s1'' = if s1' < 0 then s1' + magicNum6 else s1'
    k' = s2 // magicNum3
    s2' = magicNum4 * (s2 - k' * magicNum3) - k' * magicNum5
    s2'' = if s2' < 0 then s2' + magicNum7 else s2'
    z = s1'' - s2''
    z' = if z < 1 then z + magicNum8 else z
  in
    (z', State s1'' s2'')


split : State -> (State, State)
split (State s1 s2 as std) =
  let
    new_s1 =
      if s1 == magicNum6-1 then 1 else s1 + 1

    new_s2 =
      if s2 == 1 then magicNum7-1 else s2 - 1

    (State t1 t2) =
      snd (next std)
  in
    (State new_s1 t2, State t1 new_s2)


range : State -> (Int,Int)
range _ =
    (0, magicNum8)
