module Random
    ( Generator, Seed
    , int, intRange
    , float, floatRange
    , listOf, pairOf
    , minInt32, maxInt32
    , generate, initialSeed
    )
  where

{-| This library helps you generate pseudo-random values. The best way to use
it in your programs probably involves carrying a `Seed` in your application's
state.

Details: This is an implemenation of the Portable Combined Generator of
L'Ecuyer for 32-bit computers. It is almost a direct translation from the
[System.Random](http://hackage.haskell.org/package/random-1.0.1.1/docs/System-Random.html)
module. It has a period of roughly 2.30584e18.

# Generators for Numbers

@docs int, float, intRange, floatRange

# Generators for Data Structures

@docs pairOf, listOf

# Running a Generator

@docs generate, initialSeed

# Constants

@docs maxInt32, minInt32

# Creating Custom Generators

@docs Generator
-}

import Basics (..)
import List ((::), reverse)


{-| Generate a 32-bit integer in range [minInt32,maxInt32] inclusive.
-}
int : Generator Int
int =
    intRange minInt32 maxInt32


{-| Generate an integer in a given range. This function will continue to
produce values outside of the range [minInt32, maxInt32] but sufficient
randomness is not guaranteed.
-}
intRange : Int -> Int -> Generator Int
intRange a b seed =
    let (lo,hi) = if a < b then (a,b) else (b,a)

        k = hi - lo + 1
        -- 2^31 - 87
        b = 2147483561
        n = iLogBase b k

        f n acc state =
            case n of
              0 -> (acc, state)
              _ -> let (x, state') = seed.next state
                   in  f (n - 1) (x + acc * b) state'

        (v, state') = f n 1 seed.state
    in
        (lo + v % k, { seed | state <- state' })


iLogBase : Int -> Int -> Int       
iLogBase b i =
    if i < b then 1 else 1 + iLogBase b (i // b)


{-| The maximum value for randomly generated for 32-bit ints. -}
maxInt32 : Int
maxInt32 = 2147483647


{-| The minimum value for randomly generated for 32-bit ints. -}
minInt32 : Int
minInt32 = -2147483648


{-| Generate a float between 0 and 1 inclusive.
-}
float : Generator Float
float seed =
    let (number, seed') =
            intRange minInt32 maxInt32 seed

        zeroToOne =
            toFloat number / toFloat (maxInt32 - minInt32)
    in
        (zeroToOne, seed')


{-| Generate a float in a given range.
-}
floatRange : Float -> Float -> Generator Float
floatRange a b seed =
    let (lo, hi) = if a < b then (a,b) else (b,a)

        (zeroToOne, seed') = float seed

        scaled = lo + ((hi-lo) * zeroToOne)
    in
        (scaled, seed')


-- DATA STRUCTURES

{-| Create a pair of random values. A common use of this might be to generate
a point in a certain 2D space. Imagine we have a collage that is 400 pixels
wide and 200 pixels tall.

      randomPoint : Generator (Int,Int)
      randomPoint =
          pairOf (intRange -200 200) (intRange -100 100)

-}
pairOf : Generator a -> Generator b -> Generator (a,b)
pairOf genLeft genRight seed =
    let (left , seed' ) = genLeft seed
        (right, seed'') = genRight seed'
    in
        ((left,right), seed'')


{-| Create a list of random values using a generator function.

      floatList : Generator [Float]
      floatList = listOf 10 float

      intList : Generator [Int]
      intList = listOf 42 (intRange (0,3))

      intPairs : Generator [(Int,Int)]
      intPairs =
          listOf 10 (pairOf int int)
-}
listOf : Int -> Generator a -> Generator [a]
listOf n gen =
    listOfHelp [] n gen


listOfHelp : [a] -> Int -> Generator a -> Generator [a]
listOfHelp list n generate seed =
    if n < 1
    then (reverse list, seed)
    else
        let (value, seed') = generate seed
        in  listOfHelp (value :: list) (n-1) generate seed'

{-| A `Generator` is a function that takes a seed, and then returns a random
value and a new seed. The new seed is used to generate new random values. You
can use this to define Generators of your own. For example, here is how
`pairOf` is implemented.

      pairOf : Generator a -> Generator b -> Generator (a,b)
      pairOf genLeft genRight seed =
          let (left , seed' ) = genLeft seed
              (right, seed'') = genRight seed'
          in
              ((left,right), seed'')
-}
type alias Generator a =
    Seed -> (a, Seed)

type State = State Int Int

type alias Seed =
    { state : State
    , next  : State -> (Int, State)
    , split : State -> (State, State)
    , range : State -> (Int,Int)
    }

{-| Run a random value generator with a given seed. It will give you back a
random value and a new seed.

      seed0 = initialSeed 42

      -- generate int seed0 ==> (4123, seed1)
      -- generate int seed1 ==> (-123, seed2)
      -- generate int seed2 ==> (1021, seed3)

Notice that we use different seeds on each line. This is important! If you use
the same seed, you get the same results.

      -- generate int seed0 ==> (4123, seed1)
      -- generate int seed0 ==> (4123, seed1)
      -- generate int seed0 ==> (4123, seed1)
-}
generate : Generator a -> Seed -> (a, Seed)
generate generator seed =
    generator seed


{-| Create a &ldquo;seed&rdquo; of randomness which makes it possible to
generate random values. If you use the same seed many times, it will result
in the same thing every time!
-}
initialSeed : Int -> Seed
initialSeed n =
    Seed (initState n) next split range


{-| Produce the initial generator state. Distinct arguments should be likely
to produce distinct generator states.
-}
initState : Int -> State
initState s' =
    let s = max s' -s'
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
    let k = s1 // magicNum1 
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
    let new_s1 = if s1 == magicNum6-1 then 1 else s1 + 1
        new_s2 = if s2 == 1 then magicNum7-1 else s2 - 1
        (State t1 t2) = snd (next std)
    in
        (State new_s1 t2, State t1 new_s2)


range : State -> (Int,Int)
range _ =
    (0, magicNum8)