module JavaScript where

import Native.JavaScript
import Array (Array)
import List
import Maybe (Maybe)
import Result (Result)

type Value = Value

type Decoder a = Decoder


run : Decoder a -> Value -> Result String a
run =
    Native.JavaScript.run

--decodeWithNiceErrors : Decoder a -> Value -> Result String a

--map : (a -> b) -> Decoder a -> Decoder b

at : [String] -> Decoder a -> Decoder a
at fields decoder =
    List.foldr (:=) decoder fields


(:=) : String -> Decoder a -> Decoder a
(:=) key value =
    Native.JavaScript.decodeField key value


object1 : (a -> value) -> Decoder a -> Decoder value
object1 =
    Native.JavaScript.decodeObject1


object2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
object2 =
    Native.JavaScript.decodeObject2


object3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
object3 =
    Native.JavaScript.decodeObject3


object4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
object4 =
    Native.JavaScript.decodeObject4


object5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
object5 =
    Native.JavaScript.decodeObject5


object6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
object6 =
    Native.JavaScript.decodeObject6


object7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
object7 =
    Native.JavaScript.decodeObject7


object8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
object8 =
    Native.JavaScript.decodeObject8



--oneOf : [Decoder a] -> Decoder a


string : Decoder String
string =
    Native.JavaScript.decodeString


float : Decoder Float
float =
    Native.JavaScript.decodeFloat


int : Decoder Int
int =
    Native.JavaScript.decodeInt


bool : Decoder Bool
bool =
    Native.JavaScript.decodeBool


list : Decoder a -> Decoder [a]
list =
    Native.JavaScript.decodeList


array : Decoder a -> Decoder (Array a)
array =
    Native.JavaScript.decodeArray


null : Decoder ()
null =
    Native.JavaScript.decodeNull


maybe : Decoder a -> Decoder (Maybe a)
maybe =
    Native.JavaScript.decodeMaybe
{-
  
value : Decoder Value

tuple1 : (a -> value) -> Decoder a -> Decoder value
tuple2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
tuple3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
tuple4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
tuple5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
tuple6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
tuple7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
tuple8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
-}