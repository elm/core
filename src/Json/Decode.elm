module Json.Decode where

import Native.Json
import Array (Array)
import Json.Encode (Json)
import List
import Maybe (Maybe)
import Result (Result)


type Get a = Get


map : (a -> b) -> Get a -> Get b
map =
    Native.Json.decodeObject1


decode : Get a -> String -> Result String a
decode =
    Native.Json.decode


-- OBJECTS

at : [String] -> Get a -> Get a
at fields decoder =
    List.foldr (:=) decoder fields


(:=) : String -> Get a -> Get a
(:=) key value =
    Native.Json.decodeField key value


object1 : (a -> value) -> Get a -> Get value
object1 =
    Native.Json.decodeObject1


object2 : (a -> b -> value) -> Get a -> Get b -> Get value
object2 =
    Native.Json.decodeObject2


object3 : (a -> b -> c -> value) -> Get a -> Get b -> Get c -> Get value
object3 =
    Native.Json.decodeObject3


object4 : (a -> b -> c -> d -> value) -> Get a -> Get b -> Get c -> Get d -> Get value
object4 =
    Native.Json.decodeObject4


object5 : (a -> b -> c -> d -> e -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get value
object5 =
    Native.Json.decodeObject5


object6 : (a -> b -> c -> d -> e -> f -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get value
object6 =
    Native.Json.decodeObject6


object7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get value
object7 =
    Native.Json.decodeObject7


object8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get h -> Get value
object8 =
    Native.Json.decodeObject8



oneOf : [Get a] -> Get a
oneOf =
    Native.Json.oneOf


string : Get String
string =
    Native.Json.decodeString


float : Get Float
float =
    Native.Json.decodeFloat


int : Get Int
int =
    Native.Json.decodeInt


bool : Get Bool
bool =
    Native.Json.decodeBool


list : Get a -> Get [a]
list =
    Native.Json.decodeList


array : Get a -> Get (Array a)
array =
    Native.Json.decodeArray


null : Get ()
null =
    Native.Json.decodeNull


maybe : Get a -> Get (Maybe a)
maybe =
    Native.Json.decodeMaybe

  
{-| Useful if you need to work with crazily formatted data. For example, this
lets you create a parser for "variadic" lists where the first few types are
different, followed by 0 or more of the same type.

    variadic1 : (a -> [b] -> value) -> Get a -> Get [b] -> Get value
    variadic1 f getFirst getRest =
        list raw `andThen`

    variadicHelp1 : (a -> [b] -> value) -> Get a -> Get [b] -> [Json] -> Get value
    variadicHelp1 f getFirst getRest jsonList =
        case jsonList of
          [] -> fail "Expecting a non-empty array"
          x :: xs ->
              chain result
                let x' <- get getFirst x
                let xs' <- get getRest xs
                Ok (f x' xs')
-}
raw : Get Json
raw =
    Native.Json.decodeValue


andThen : Get a -> (a -> Get b) -> Get b
andThen =
    Native.Json.andThen


-- TUPLES

tuple1 : (a -> value) -> Get a -> Get value
tuple1 =
    Native.Json.decodeTuple1


tuple2 : (a -> b -> value) -> Get a -> Get b -> Get value
tuple2 =
    Native.Json.decodeTuple2


tuple3 : (a -> b -> c -> value) -> Get a -> Get b -> Get c -> Get value
tuple3 =
    Native.Json.decodeTuple3


tuple4 : (a -> b -> c -> d -> value) -> Get a -> Get b -> Get c -> Get d -> Get value
tuple4 =
    Native.Json.decodeTuple4


tuple5 : (a -> b -> c -> d -> e -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get value
tuple5 =
    Native.Json.decodeTuple5


tuple6 : (a -> b -> c -> d -> e -> f -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get value
tuple6 =
    Native.Json.decodeTuple6


tuple7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get value
tuple7 =
    Native.Json.decodeTuple7


tuple8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Get a -> Get b -> Get c -> Get d -> Get e -> Get f -> Get g -> Get h -> Get value
tuple8 =
    Native.Json.decodeTuple8