module JavaScript where

import Native.JavaScript
import Array (Array)
import List
import Maybe (Maybe)
import Result (Result)

type Value = Value

type Get a = Get


get : Get a -> Value -> Result String a
get =
    Native.JavaScript.get


map : (a -> b) -> Get a -> Get b
map =
    Native.JavaScript.decodeObject1


toString : String -> Value a -> String
toString =
    Native.JavaScript.toString


fromString : String -> Result String Value
fromString =
    Native.JavaScript.fromString


-- OBJECTS

at : [String] -> Get a -> Get a
at fields decoder =
    List.foldr (:=) decoder fields


(:=) : String -> Get a -> Get a
(:=) key value =
    Native.JavaScript.decodeField key value


object1 : (a -> value) -> Get a -> Get value
object1 =
    Native.JavaScript.decodeObject1


object2 : (a -> b -> value) -> Get a -> Get b -> Get value
object2 =
    Native.JavaScript.decodeObject2


object3 : (a -> b -> c -> value) -> Get a -> Get b -> Get c -> Get value
object3 =
    Native.JavaScript.decodeObject3


object4 : (a -> b -> c -> d -> value) -> Get a -> Get b -> Get c -> Get d -> Get value
object4 =
    Native.JavaScript.decodeObject4


object5 : (a -> b -> c -> d -> e -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get value
object5 =
    Native.JavaScript.decodeObject5


object6 : (a -> b -> c -> d -> e -> f -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get value
object6 =
    Native.JavaScript.decodeObject6


object7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get value
object7 =
    Native.JavaScript.decodeObject7


object8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get h -> Get value
object8 =
    Native.JavaScript.decodeObject8



oneOf : [Get a] -> Get a
oneOf =
    Native.JavaScript.oneOf


string : Get String
string =
    Native.JavaScript.decodeString


float : Get Float
float =
    Native.JavaScript.decodeFloat


int : Get Int
int =
    Native.JavaScript.decodeInt


bool : Get Bool
bool =
    Native.JavaScript.decodeBool


list : Get a -> Get [a]
list =
    Native.JavaScript.decodeList


array : Get a -> Get (Array a)
array =
    Native.JavaScript.decodeArray


null : Get ()
null =
    Native.JavaScript.decodeNull


maybe : Get a -> Get (Maybe a)
maybe =
    Native.JavaScript.decodeMaybe

  
{-| Useful when you need to do some more advanced extraction on arrays. Say
you have an array that starts with a string and then an unknown amount of
numbers.

    -- [ "Callisto", 1, 2, 3, 4 ]

    extract : Json -> Result String (String, [Int])
    extract json =
        case get (list jsonValue) json of
          str :: numbers ->
              get string str
              get (list int) numbers

-}
jsonValue : Get Value
jsonValue =
    Native.JavaScript.decodeValue


andThen : Get a -> (a -> Get b) -> Get b
andThen =
    Native.JavaScript.andThen


-- TUPLES

tuple1 : (a -> value) -> Get a -> Get value
tuple1 =
    Native.JavaScript.decodeTuple1


tuple2 : (a -> b -> value) -> Get a -> Get b -> Get value
tuple2 =
    Native.JavaScript.decodeTuple2


tuple3 : (a -> b -> c -> value) -> Get a -> Get b -> Get c -> Get value
tuple3 =
    Native.JavaScript.decodeTuple3


tuple4 : (a -> b -> c -> d -> value) -> Get a -> Get b -> Get c -> Get d -> Get value
tuple4 =
    Native.JavaScript.decodeTuple4


tuple5 : (a -> b -> c -> d -> e -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get value
tuple5 =
    Native.JavaScript.decodeTuple5


tuple6 : (a -> b -> c -> d -> e -> f -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get value
tuple6 =
    Native.JavaScript.decodeTuple6


tuple7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get value
tuple7 =
    Native.JavaScript.decodeTuple7


tuple8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get h -> Get value
tuple8 =
    Native.JavaScript.decodeTuple8