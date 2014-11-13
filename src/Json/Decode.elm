module Json.Decode where

import Native.Json
import Array (Array)
import Json.Encode as JsonEncode
import List
import Maybe (Maybe)
import Result (Result)


type Decoder a = Decoder

type alias Json = JsonEncode.Json


map : (a -> b) -> Decoder a -> Decoder b
map =
    Native.Json.decodeObject1


decode : Decoder a -> String -> Result String a
decode =
    Native.Json.decode


-- OBJECTS

at : [String] -> Decoder a -> Decoder a
at fields decoder =
    List.foldr (:=) decoder fields


(:=) : String -> Decoder a -> Decoder a
(:=) key value =
    Native.Json.decodeField key value


object1 : (a -> value) -> Decoder a -> Decoder value
object1 =
    Native.Json.decodeObject1


object2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
object2 =
    Native.Json.decodeObject2


object3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
object3 =
    Native.Json.decodeObject3


object4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
object4 =
    Native.Json.decodeObject4


object5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
object5 =
    Native.Json.decodeObject5


object6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
object6 =
    Native.Json.decodeObject6


object7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
object7 =
    Native.Json.decodeObject7


object8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
object8 =
    Native.Json.decodeObject8



oneOf : [Decoder a] -> Decoder a
oneOf =
    Native.Json.oneOf


string : Decoder String
string =
    Native.Json.decodeString


float : Decoder Float
float =
    Native.Json.decodeFloat


int : Decoder Int
int =
    Native.Json.decodeInt


bool : Decoder Bool
bool =
    Native.Json.decodeBool


list : Decoder a -> Decoder [a]
list =
    Native.Json.decodeList


array : Decoder a -> Decoder (Array a)
array =
    Native.Json.decodeArray


null : Decoder ()
null =
    Native.Json.decodeNull


maybe : Decoder a -> Decoder (Maybe a)
maybe =
    Native.Json.decodeMaybe

  
{-| Useful if you need to work with crazily formatted data. For example, this
lets you create a parser for "variadic" lists where the first few types are
different, followed by 0 or more of the same type.

    variadic2 : (a -> b -> [c] -> value) -> Decoder a -> Decoder b -> Decoder [c] -> Decoder value
    variadic2 f a b cs =
        customDecoder (list raw) \jsonList ->
            case jsonList of
              one :: two :: rest ->
                  Result.map3 f
                    (decodeRaw a one)
                    (decodeRaw b two)
                    (decodeRaw cs rest)

              _ -> Result.Err "expecting at least two elements in the array"
-}
raw : Decoder Json
raw =
    Native.Json.decodeJson


decodeRaw : Decoder a -> Json -> Result String a
decodeRaw =
    Native.Json.decodeRaw


customDecoder : Decoder a -> (a -> Result String b) -> Decoder b
customDecoder =
    Native.Json.customDecoder


andThen : Decoder a -> (a -> Decoder b) -> Decoder b
andThen =
    Native.Json.andThen


-- TUPLES

tuple1 : (a -> value) -> Decoder a -> Decoder value
tuple1 =
    Native.Json.decodeTuple1


tuple2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
tuple2 =
    Native.Json.decodeTuple2


tuple3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
tuple3 =
    Native.Json.decodeTuple3


tuple4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
tuple4 =
    Native.Json.decodeTuple4


tuple5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
tuple5 =
    Native.Json.decodeTuple5


tuple6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
tuple6 =
    Native.Json.decodeTuple6


tuple7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
tuple7 =
    Native.Json.decodeTuple7


tuple8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
tuple8 =
    Native.Json.decodeTuple8