module Http where

import Native.Http
import JavaScript as JS


-- REQUESTS

type alias Request =
    { verb : String
    , headers : List (String, String)
    , url : String
    , body : Body
    }


-- BODY

type Body
    = Empty
    | Str String
    | ArrayBuffer
    | FormData
    | Blob


empty : Body
empty =
  Empty


string : String -> Body
string =
  Str


blob : Blob -> Body
blob =
  Blob


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


-- TIMEOUT

type Timeout
    = Never
    | After Int (Promise x a)


-- PROGRESS

type alias Progress =
    { lengthComputable : Int
    , loaded : Int
    , total : Int
    }
    -> Promise x a


-- RESPONSE HANDLER

type ResponseHandler a =
    Handler ResponseType (headers -> J


-- ACTUALLY SEND REQUESTS

{-| Send a request.
-}
send : Request -> Timeout -> Progress -> ResponseHandler a -> Promise Error a
send =
  Native.Http.send



{-| Send a GET request to the given url. You also specify how to decode the
response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      get (list string) "http://example.com/hat-categories.json"

-}
get : JS.Decoder a -> String -> Promise Error a
get decoder url =
  send Nothing decoder
    { verb = "GET"
    , headers = []
    , url = url
    , body = empty
    }



{-| Send a POST send to the given url, carrying the given string as the body.
You also specify how to decode the response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      post (list string) "http://example.com/hat-categories.json" ""

-}
post : JS.Decoder a -> String -> Body -> Promise Error a
post url body =
  send Nothing decoder
    { verb = "POST"
    , headers = []
    , url = url
    , body = body
    }
