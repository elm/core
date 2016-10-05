module Json.Decode exposing
  ( Decoder, string, bool, int, float
  , list, array, dict, keyValuePairs
  , field, at, index
  , maybe, oneOf
  , object1, object2, object3, object4, object5, object6, object7, object8
  , decodeString, decodeValue, Value
  , map, succeed, fail, andThen, value, null
  )



import Array exposing (Array)
import Dict exposing (Dict)
import Json.Encode as JsEncode
import List
import Maybe exposing (Maybe)
import Result exposing (Result)
import Native.Json



-- PRIMITIVES


type Decoder a = Decoder


string : Decoder String
string =
  Native.Json.decodePrimitive "string"


bool : Decoder Bool
bool =
  Native.Json.decodePrimitive "bool"


int : Decoder Int
int =
  Native.Json.decodePrimitive "int"


float : Decoder Float
float =
  Native.Json.decodePrimitive "float"



-- DATA STRUCTURES


list : Decoder a -> Decoder (List a)
list decoder =
  Native.Json.decodeContainer "list" decoder


array : Decoder a -> Decoder (Array a)
array decoder =
  Native.Json.decodeContainer "array" decoder


dict : Decoder a -> Decoder (Dict String a)
dict decoder =
    map Dict.fromList (keyValuePairs decoder)


keyValuePairs : Decoder a -> Decoder (List (String, a))
keyValuePairs =
    Native.Json.decodeKeyValuePairs



-- OBJECT PRIMITIVES


field : String -> Decoder a -> Decoder a
field =
    Native.Json.decodeField


at : List String -> Decoder a -> Decoder a
at fields decoder =
    List.foldr field decoder fields


index : Int -> Decoder a -> Decoder a
index =
    Native.Json.decodeIndex


-- WEIRD STRUCTURE


maybe : Decoder a -> Decoder (Maybe a)
maybe decoder =
  Native.Json.decodeContainer "maybe" decoder


oneOf : List (Decoder a) -> Decoder a
oneOf =
    Native.Json.oneOf



-- OBJECT HELPERS


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



-- RUN DECODERS


decodeString : Decoder a -> String -> Result String a
decodeString =
  Native.Json.runOnString


decodeValue : Decoder a -> Value -> Result String a
decodeValue =
  Native.Json.run


type alias Value = JsEncode.Value



-- FANCY PRIMITIVES


map : (a -> b) -> Decoder a -> Decoder b
map =
  Native.Json.decodeObject1


succeed : a -> Decoder a
succeed =
  Native.Json.succeed


fail : String -> Decoder a
fail =
  Native.Json.fail


andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen =
  Native.Json.andThen


value : Decoder Value
value =
  Native.Json.decodePrimitive "value"


null : a -> Decoder a
null =
  Native.Json.decodeNull
