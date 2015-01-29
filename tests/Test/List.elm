module Test.List (tests) where

import ElmTest.Assertion (..)
import ElmTest.Test (..)

import Basics (..)
import Maybe (Maybe(Nothing, Just))
import List (..)


tests : Test
tests = suite "List Tests"
  [ testListOfN 0
  , testListOfN 1
  , testListOfN 2
  , testListOfN 100
  , testListOfN 1000
  ]
  

testListOfN : Int -> Test
testListOfN n =
  let xs = [1..n]
      xsP1 = [2..(n + 1)]
      zs = [0..n]
      mid = n // 2
      sumXs = n * (n + 1) // 2
      rev x = n - x + 1
  in
      suite (toString n ++ " elements")
        [ suite "foldl"
            [ test "order" <| assertEqual (n) (foldl (\x acc -> x) 0 xs)
            , test "total" <| assertEqual (sumXs) (foldl (+) 0 xs)
            ]
            
        , suite "foldr"
            [ test "order" <| assertEqual (min 1 n) (foldr (\x acc -> x) 0 xs)
            , test "total" <| assertEqual (sumXs) (foldl (+) 0 xs)
            ]
            
        , suite "map"
            [ test "identity" <| assertEqual (xs) (map identity xs)
            , test "linear" <| assertEqual ([2..(n + 1)]) (map ((+) 1) xs)
            ]
            
        , test "isEmpty" <| assertEqual (n == 0) (isEmpty xs)
        
        , test "length" <| assertEqual (n) (length xs)
        
        , test "reverse" <| assertEqual (map rev xs) (reverse xs)
        
        , suite "member" 
            [ test "positive" <| assertEqual (True) (member n zs)
            , test "negative" <| assertEqual (False) (member (n + 1) xs)
            ]
            
        , test "head" <|
            if n == 0
            then assertEqual (Nothing) (head xs)
            else assertEqual (Just 1) (head xs)
            
        , test "uncons" <|
            if n == 0
            then assertEqual (Nothing) (uncons xs)
            else assertEqual (Just (1, [2..n])) (uncons xs)
            
        , suite "filter"
            [ test "none" <| assertEqual ([]) (filter (\x -> x > n) xs)
            , test "one" <| assertEqual ([n]) (filter (\z -> z == n) zs)
            , test "all" <| assertEqual (xs) (filter (\x -> x <= n) xs)
            ]
            
        , suite "take"
            [ test "none" <| assertEqual ([]) (take 0 xs)
            , test "some" <| assertEqual ([0..(n - 1)]) (take n zs)
            , test "all" <| assertEqual (xs) (take n xs)
            , test "all+" <| assertEqual (xs) (take (n + 1) xs)
            ]
            
        , suite "drop"
            [ test "none" <| assertEqual (xs) (drop 0 xs)
            , test "some" <| assertEqual ([n]) (drop n zs)
            , test "all" <| assertEqual ([]) (drop n xs)
            , test "all+" <| assertEqual ([]) (drop (n + 1) xs)
            ]
            
        , test "repeat" <| assertEqual (map (\x -> -1) xs) (repeat n -1)
        
        , test "append" <| assertEqual (sumXs * 2) (append xs xs |> foldl (+) 0)
        
        , test "(::)" <| assertEqual (append [-1] xs) (-1 :: xs)
        
        , test "concat" <| assertEqual (append xs (append zs xs)) (concat [xs, zs, xs])
        
        , test "intersperse" <| assertEqual 
            (min -(n - 1) 0, sumXs)
            (intersperse -1 xs |> foldl (\x (c1, c2) -> (c2, c1 + x)) (0, 0))
            
        , suite "partition"
            [ test "left" <| assertEqual (xs, []) (partition (\x -> x > 0) xs)
            , test "right" <| assertEqual ([], xs) (partition (\x -> x < 0) xs)
            , test "split" <| assertEqual ([(mid + 1)..n], [1..mid]) (partition ((<) mid) xs)
            ]
            
        , suite "map2" 
            [ test "same length" <| assertEqual (map ((*) 2) xs) (map2 (+) xs xs)
            , test "long first" <| assertEqual (map (\x -> x * 2 - 1) xs) (map2 (+) zs xs)
            , test "short first" <| assertEqual (map (\x -> x * 2 - 1) xs) (map2 (+) xs zs)
            ]
            
        , test "unzip" <| assertEqual ((reverse xs), xs) (map (\x -> (rev x, x)) xs |> unzip)
        
        , suite "filterMap"
            [ test "none" <| assertEqual ([]) (filterMap (\x -> Nothing) xs)
            , test "all" <| assertEqual (xsP1) (filterMap (\x -> Just (x + 1)) xs)
            , let halve x = 
                    if x % 2 == 0
                    then Just (x // 2) 
                    else Nothing
              in  
                  test "some" <| assertEqual ([1..mid]) (filterMap halve xs)
            ]
            
        , suite "concatMap"
            [ test "none" <| assertEqual ([]) (concatMap (\x -> []) xs)
            , test "all" <| assertEqual (xsP1) (concatMap (\x -> [x + 1]) xs)
            ]
            
        , test "indexedMap" <| assertEqual (map2 (,) zs xsP1) (indexedMap (\i x -> (i, x + 1)) xs)
        
        , test "sum" <| assertEqual (sumXs) (sum xs)
        
        , test "product" <| assertEqual (0) (product zs)
        
        , test "maximum" <|
            if n == 0
            then assertEqual (Nothing) (maximum xs)
            else assertEqual (Just n) (maximum xs)
        
        , test "minimum" <|
            if n == 0
            then assertEqual (Nothing) (minimum xs)
            else assertEqual (Just 1) (minimum xs)
        
        , suite "all"
            [ test "false" <| assertEqual (False) (all (\z -> z < n) zs)
            , test "true" <| assertEqual (True) (all (\x -> x <= n) xs)
            ]
            
        , suite "any"
            [ test "false" <| assertEqual (False) (any (\x -> x > n) xs)
            , test "true" <| assertEqual (True) (any (\z -> z >= n) zs)
            ]
            
        , suite "sort"
            [ test "sorted" <| assertEqual (xs) (sort xs)
            , test "unsorted" <| assertEqual (xs) (sort (reverse xs))
            ]
            
        , suite "sortBy"
            [ test "sorted" <| assertEqual (reverse xs) (sortBy negate (reverse xs))
            , test "unsorted" <| assertEqual (reverse xs) (sortBy negate xs)
            ]
            
        , suite "sortWith"
            [ test "sorted" <| assertEqual (reverse xs) (sortWith (flip compare) (reverse xs))
            , test "unsorted" <| assertEqual (reverse xs) (sortWith (flip compare) xs)
            ]
        ]
