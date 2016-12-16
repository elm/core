module Test.Array exposing (tests)

import Array
import Basics exposing (..)
import List
import List exposing ((::))
import Maybe exposing (..)
import Native.Array
import Test exposing (..)
import Expect


mergeSplit : Int -> Array.Array a -> Array.Array a
mergeSplit n arr =
    let
        left =
            Array.slice 0 n arr

        right =
            Array.slice n (Array.length arr) arr
    in
        Array.append left right


holeArray : Array.Array Int
holeArray =
    List.foldl mergeSplit (Array.fromList (List.range 0 100)) (List.range 0 100)


mapArray : Array.Array a -> Array.Array a
mapArray array =
    Array.indexedMap
        (\i el ->
            case (Array.get i array) of
                Just x ->
                    x

                Nothing ->
                    el
        )
        array


tests : Test
tests =
    let
        creationTests =
            describe "Creation"
                [ test "empty" <| \() -> Expect.equal Array.empty (Array.fromList [])
                , test "initialize" <| \() -> Expect.equal (Array.initialize 4 identity) (Array.fromList [ 0, 1, 2, 3 ])
                , test "initialize 2" <| \() -> Expect.equal (Array.initialize 4 (\n -> n * n)) (Array.fromList [ 0, 1, 4, 9 ])
                , test "initialize 3" <| \() -> Expect.equal (Array.initialize 4 (always 0)) (Array.fromList [ 0, 0, 0, 0 ])
                , test "initialize Empty" <| \() -> Expect.equal (Array.initialize 0 identity) Array.empty
                , test "initialize 4" <| \() -> Expect.equal (Array.initialize 2 (always 0)) (Array.fromList [ 0, 0 ])
                , test "initialize negative" <| \() -> Expect.equal (Array.initialize -1 identity) Array.empty
                , test "repeat" <| \() -> Expect.equal (Array.repeat 5 40) (Array.fromList [ 40, 40, 40, 40, 40 ])
                , test "repeat 2" <| \() -> Expect.equal (Array.repeat 5 0) (Array.fromList [ 0, 0, 0, 0, 0 ])
                , test "repeat 3" <| \() -> Expect.equal (Array.repeat 3 "cat") (Array.fromList [ "cat", "cat", "cat" ])
                , test "fromList" <| \() -> Expect.equal (Array.fromList []) Array.empty
                ]

        basicsTests =
            describe "Basics"
                [ test "length" <| \() -> Expect.equal 3 (Array.length (Array.fromList [ 1, 2, 3 ]))
                , test "length - Long" <| \() -> Expect.equal 10000 (Array.length (Array.repeat 10000 0))
                , test "push" <| \() -> Expect.equal (Array.fromList [ 1, 2, 3 ]) (Array.push 3 (Array.fromList [ 1, 2 ]))
                , test "append" <| \() -> Expect.equal [ 42, 42, 81, 81, 81 ] (Array.toList (Array.append (Array.repeat 2 42) (Array.repeat 3 81)))
                , test "appendEmpty 1" <| \() -> Expect.equal (List.range 1 33) (Array.toList (Array.append Array.empty (Array.fromList <| List.range 1 33)))
                , test "appendEmpty 2" <| \() -> Expect.equal (List.range 1 33) (Array.toList (Array.append (Array.fromList <| List.range 1 33) Array.empty))
                , test "appendSmall 1" <| \() -> Expect.equal (List.range 1 33) (Array.toList (Array.append (Array.fromList <| List.range 1 30) (Array.fromList <| List.range 31 33)))
                , test "appendSmall 2" <| \() -> Expect.equal (List.range 1 33) (Array.toList (Array.append (Array.fromList <| List.range 1 3) (Array.fromList <| List.range 4 33)))
                , test "appendAndSlice" <| \() -> Expect.equal (List.range 0 100) (Array.toList holeArray)
                ]

        getAndSetTests =
            describe "Get and Set"
                [ test "get" <| \() -> Expect.equal (Just 2) (Array.get 1 (Array.fromList [ 3, 2, 1 ]))
                , test "get 2" <| \() -> Expect.equal Nothing (Array.get 5 (Array.fromList [ 3, 2, 1 ]))
                , test "get 3" <| \() -> Expect.equal Nothing (Array.get -1 (Array.fromList [ 3, 2, 1 ]))
                , test "set" <| \() -> Expect.equal (Array.fromList [ 1, 7, 3 ]) (Array.set 1 7 (Array.fromList [ 1, 2, 3 ]))
                ]

        takingArraysApartTests =
            describe "Taking Arrays Apart"
                [ test "toList" <| \() -> Expect.equal [ 3, 5, 8 ] (Array.toList (Array.fromList [ 3, 5, 8 ]))
                , test "toIndexedList" <| \() -> Expect.equal [ ( 0, "cat" ), ( 1, "dog" ) ] (Array.toIndexedList (Array.fromList [ "cat", "dog" ]))
                , test "slice 1" <| \() -> Expect.equal (Array.fromList [ 0, 1, 2 ]) (Array.slice 0 3 (Array.fromList [ 0, 1, 2, 3, 4 ]))
                , test "slice 2" <| \() -> Expect.equal (Array.fromList [ 1, 2, 3 ]) (Array.slice 1 4 (Array.fromList [ 0, 1, 2, 3, 4 ]))
                , test "slice 3" <| \() -> Expect.equal (Array.fromList [ 1, 2, 3 ]) (Array.slice 1 -1 (Array.fromList [ 0, 1, 2, 3, 4 ]))
                , test "slice 4" <| \() -> Expect.equal (Array.fromList [ 2 ]) (Array.slice -3 -2 (Array.fromList [ 0, 1, 2, 3, 4 ]))
                , test "slice 5" <| \() -> Expect.equal 63 (Array.length <| Array.slice 65 (65 + 63) <| Array.fromList (List.range 1 200))
                ]

        mappingAndFoldingTests =
            describe "Mapping and Folding"
                [ test "map" <| \() -> Expect.equal (Array.fromList [ 1, 2, 3 ]) (Array.map sqrt (Array.fromList [ 1, 4, 9 ]))
                , test "indexedMap 1" <| \() -> Expect.equal (Array.fromList [ 0, 5, 10 ]) (Array.indexedMap (*) (Array.fromList [ 5, 5, 5 ]))
                , test "indexedMap 2" <| \() -> Expect.equal (List.range 0 99) (Array.toList (Array.indexedMap always (Array.repeat 100 0)))
                , test "large indexed map" <| \() -> Expect.equal (List.range 0 <| 32768 - 1) (Array.toList <| mapArray <| Array.initialize 32768 identity)
                , test "foldl 1" <| \() -> Expect.equal [ 3, 2, 1 ] (Array.foldl (::) [] (Array.fromList [ 1, 2, 3 ]))
                , test "foldl 2" <| \() -> Expect.equal 33 (Array.foldl (+) 0 (Array.repeat 33 1))
                , test "foldr 1" <| \() -> Expect.equal 15 (Array.foldr (+) 0 (Array.repeat 3 5))
                , test "foldr 2" <| \() -> Expect.equal [ 1, 2, 3 ] (Array.foldr (::) [] (Array.fromList [ 1, 2, 3 ]))
                , test "foldr 3" <| \() -> Expect.equal 53 (Array.foldr (-) 54 (Array.fromList [ 10, 11 ]))
                , test "filter" <| \() -> Expect.equal (Array.fromList [ 2, 4, 6 ]) (Array.filter (\x -> x % 2 == 0) (Array.fromList <| List.range 1 6))
                ]

        nativeTests =
            describe "Conversion to JS Arrays"
                [ test "jsArrays" <| \() -> Expect.equal (Array.fromList <| List.range 1 1100) (Native.Array.fromJSArray (Native.Array.toJSArray (Array.fromList <| List.range 1 1100)))
                ]
    in
        describe "Array"
            [ creationTests
            , basicsTests
            , getAndSetTests
            , takingArraysApartTests
            , mappingAndFoldingTests
            , nativeTests
            ]
