module Http
    ( get, post, send
    , Request
    , Body, empty, string, blob, multipart
    , Data, stringData, blobData, fileData
    , Settings, defaultSettings, never, Progress
    , Response, Value(..)
    , Error
    ) where
{-|

# Fetching JSON
@docs get, post

# Body Values
@docs empty, string, blob, multipart, stringData, blobData, fileData

# Arbitrariy Requests
@docs send, Request, Response, Value, Error

# Settings
@docs Settings, defaultSettigs, Progress

-}
import Basics ((&&), (<=), (<))
import Dict (Dict)
import JavaScript.Decode as JavaScript
import Maybe (Maybe(..))
import Native.Http
import Promise (Promise, andThen, succeed, fail)
import Result (Result(..))


type Blob = TODO_impliment_blob_in_another_library
type File = TODO_impliment_file_in_another_library


-- REQUESTS

type alias Request =
    { verb : String
    , headers : List (String, String)
    , url : String
    , body : Body
    }


type Body
    = Empty
    | BodyString String
    | ArrayBuffer
    | BodyFormData
    | BodyBlob


empty : Body
empty =
  Empty


string : String -> Body
string =
  BodyString


-- arrayBuffer : ArrayBuffer -> Body


blob : Blob -> Body
blob _ =
  BodyBlob


type Data
    = StringData String String
    | BlobData String (Maybe String) Blob
    | FileData String (Maybe String) File


multipart : List Data -> Body
multipart =
  Native.Http.multipart


stringData : String -> String -> Data
stringData =
  StringData


blobData : String -> Maybe String -> Blob -> Data
blobData =
  BlobData


fileData : String -> Maybe String -> File -> Data
fileData =
  FileData


-- SETTINGS

type alias Settings =
    { timeout : Int
    , onStart : Maybe (Promise () ())
    , onProgress : Maybe (Progress -> Promise () ())
    , desiredResponseType : Maybe String
    }


never : Int
never = 0


type alias Progress =
    { lengthComputable : Int
    , loaded : Int
    , total : Int
    }


defaultSettings : Settings
defaultSettings =
    { timeout = never
    , onStart = Nothing
    , onProgress = Nothing
    , desiredResponseType = Nothing
    }


-- RESPONSE HANDLER

type alias Response =
    { status : Int
    , statusText : String
    , headers : Dict String String
    , url : String
    , value : Value
    }


type Value
    = Text String
--    | ArrayBuffer ArrayBuffer
    | Blob Blob
--    | Document Document


-- Errors

type Error
    = Timeout
    | NetworkError
    | Other


-- ACTUALLY SEND REQUESTS

{-| Send a request exactly how you want it. The `Settings` argument lets you
configure things like timeouts and progress monitoring. The `Request` argument
defines all the information that will actually be sent along to a server.

    crossOriginGet : String -> String -> Promise Error Response
    crossOriginGet origin url =
      send defaultSettings
        { verb = "GET"
        , headers = [("Origin", origin)]
        , url = url
        , body = empty
        }
-}
send : Settings -> Request -> Promise Error Response
send =
  Native.Http.send



{-| Send a GET request to the given url. You also specify how to decode the
response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      get (list string) "http://example.com/hat-categories.json"

-}
get : JavaScript.Decoder a -> String -> Promise Error a
get decoder url =
  let request =
        { verb = "GET"
        , headers = []
        , url = url
        , body = empty
        }
  in
      send defaultSettings request `andThen` decodeResponse decoder


{-| Send a POST send to the given url, carrying the given string as the body.
You also specify how to decode the response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      post (list string) "http://example.com/hat-categories.json" empty

-}
post : JavaScript.Decoder a -> String -> Body -> Promise Error a
post decoder url body =
  let request =
        { verb = "POST"
        , headers = []
        , url = url
        , body = body
        }
  in
      send defaultSettings request `andThen` decodeResponse decoder


decodeResponse : JavaScript.Decoder a -> Response -> Promise Error a
decodeResponse decoder response =
  case 200 <= response.status && response.status < 300 of
    True ->
      case response.value of
        Text rawJson ->
          case JavaScript.decodeString decoder rawJson of
            Ok v -> succeed v
            Err msg -> fail NetworkError

        _ -> fail Other

    False ->
      fail Other
