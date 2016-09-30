module Http exposing
  ( Request, send, Error
  , getString, get
  , post
  , request
  , Header, header
  , Body, emptyBody, jsonBody, stringBody, multipartBody, Part, stringPart
  , Expect, expectNothing, expectString, expectJson, expectStringResponse, Response
  , encodeUri, decodeUri, toTask
  )

{-|

# Send Requests
@docs Request, send, Error

# GET
@docs getString, get

# POST
@docs post

# Custom Requests
@docs request

## Headers
@docs Header, header

## Request Bodies
@docs Body, emptyBody, jsonBody, stringBody, multipartBody, Part, stringPart

## Responses
@docs Expect, expectNothing, expectString, expectJson, expectStringResponse, Response

# Low-Level
@docs encodeUri, decodeUri, toTask

-}

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode
import Maybe exposing (Maybe(..))
import Native.Http
import Platform.Cmd as Cmd exposing (Cmd)
import Result exposing (Result(..))
import Task exposing (Task)
import Time exposing (Time)



-- REQUESTS


{-| Describes an HTTP request.
-}
type Request a =
  Request
    { method : String
    , headers : List Header
    , url : String
    , body : Body
    , expect : Expect a
    , timeout : Maybe Time
    , withCredentials : Bool
    }


{-| Send a `Request`. We could get the text of “War and Peace” like this:

    import Http

    type Msg = Click | NewBook (Result Http.Error String)

    update : Msg -> Model -> Model
    update msg model =
      case msg of
        Click ->
          ( model, getWarAndPeace )

        NewBook (Ok book) ->
          ...

        NewBook (Err _) ->
          ...

    getWarAndPeace : Cmd Msg
    getWarAndPeace =
      Http.send NewBook <|
        Http.getString "https://example.com/books/war-and-peace.md"
-}
send : (Result Error a -> msg) -> Request a -> Cmd msg
send resultToMessage request =
  Task.perform resultToMessage (toTask request)


{-| Convert a `Request` into a `Task`. This is only really useful if you want
to chain together a bunch of requests (or any other tasks) in a single command.
-}
toTask : Request a -> Task Error a
toTask (Request request) =
  Native.Http.toTask request


{-| A `Request` can fail in a couple ways:

  - `BadUrl` means you did not provide a valid URL.
  - `Timeout` means it took too long to get a response.
  - `NetworkError` means the user turned off their wifi, went in a cave, etc.
  - `BadStatus` means you got a response back, but the [status code][sc]
    indicates failure.
  - `BadPayload` means you got a response back with a nice status code, but
    the body of the response was something unexpected. The `String` in this
    case is a debugging message that explains what went wrong with your JSON
    decoder or whatever.

[sc]: https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
-}
type Error
  = BadUrl String
  | Timeout
  | NetworkError
  | BadStatus (Response String)
  | BadPayload String (Response String)



-- GET


getString : String -> Request String
getString url =
  request
    { method = "GET"
    , headers = []
    , url = url
    , body = emptyBody
    , expect = expectString
    , timeout = Nothing
    , withCredentials = False
    }


get : String -> Decode.Decoder a -> Request a
get url decoder =
  request
    { method = "GET"
    , headers = []
    , url = url
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }



-- POST


post : String -> Body -> Decode.Decoder a -> Request a
post url body decoder =
  request
    { method = "POST"
    , headers = []
    , url = url
    , body = body
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }



-- CUSTOM REQUESTS


{-| Create a custom request. For example, a custom PUT request would look like
this:

    put : String -> Body -> Request ()
    put url body =
      request
        { method = "PUT"
        , headers = []
        , url = url
        , body = body
        , expect = expectNothing
        , timeout = Nothing
        , withCredentials = False
        }
-}
request
  : { method : String
    , headers : List Header
    , url : String
    , body : Body
    , expect : Expect a
    , timeout : Maybe Time
    , withCredentials : Bool
    }
  -> Request a
request =
  Request



-- HEADERS


type Header = Header String String


header : String -> String -> Header
header =
  Header



-- BODY


{-| Represents the body of a `Request`.
-}
type Body
  = EmptyBody
  | StringBody String String
  | FormDataBody


{-| Create an empty body for your `Request`. This is useful for GET requests
and POST requests where you are not sending any data.
-}
emptyBody : Body
emptyBody =
  EmptyBody


{-| Put some JSON value in the body of your `Request`. This will automatically
add the `Content-Type: application/json` header.
-}
jsonBody : Encode.Value -> Body
jsonBody value =
  StringBody "application/json" (Encode.encode 0 value)


{-| Put some string in the body of your `Request`. Defining `jsonBody` looks
like this:

    import Json.Encode as Encode

    jsonBody : Encode.Value -> Body
    jsonBody value =
      stringBody "application/json" (Encode.encode 0 value)

Notice that the first argument is a [MIME type][mime] so we know to add
`Content-Type: application/json` to our request headers. Make sure your
MIME type matches your data. Some servers are strict about this!

[mime]: https://en.wikipedia.org/wiki/Media_type
-}
stringBody : String -> String -> Body
stringBody =
  StringBody


{-| Create multi-part bodies for your `Request`, automatically adding the
`Content-Type: multipart/form-data` header.
-}
multipartBody : List Part -> Body
multipartBody =
  Native.Http.multipart


{-| Contents of a multi-part body. Right now it only supports strings, but we
will support blobs and files when we get an API for them in Elm.
-}
type Part
  = StringPart String String


{-| A named chunk of string data.

    body =
      multipartBody
        [ stringPart "user" "tom"
        , stringPart "payload" "42"
        ]
-}
stringPart : String -> String -> Part
stringPart =
  StringPart



-- RESPONSES


type Expect a = Expect


expectNothing : Expect ()
expectNothing =
  expectStringResponse (\_ -> Ok ())


expectString : Expect String
expectString =
  expectStringResponse (\response -> Ok response.body)


expectJson : Decode.Decoder a -> Expect a
expectJson decoder =
  expectStringResponse (\response -> Decode.decodeString decoder response.body)


expectStringResponse : (Response String -> Result String a) -> Expect a
expectStringResponse =
  Native.Http.expectStringResponse


{-| The response from a `Request`.
-}
type alias Response body =
    { url : String
    , status : { code : Int, message : String }
    , headers : Dict String String
    , body : body
    }



-- LOW-LEVEL


{-| Use this to escape query parameters. Converts characters like `/` to `%2F`
so that it does not clash with normal URL

It work just like `encodeURIComponent` in JavaScript.
-}
encodeUri : String -> String
encodeUri =
  Native.Http.encodeUri


{-| Use this to unescape query parameters. It converts things like `%2F` to
`/`. It can fail in some cases. For example, there is no way to unescape `%`
because it could never appear alone in a properly escaped string.

It works just like `decodeURIComponent` in JavaScript.
-}
decodeUri : String -> Maybe String
decodeUri =
  Native.Http.decodeUri



{-- PARALLEL REQUESTS

race : Request a -> List (Request a) -> Request a
parallel : List (Request a) -> Request (List a)
parallel2 : (a -> b -> result) -> Request a -> Request b -> Request result
parallel3 : (a -> b -> c -> result) -> Request a -> Request b -> Request c -> Request result
parallel4 : (a -> b -> c -> d -> result) -> Request a -> Request b -> Request c -> Request d -> Request result
parallel5 : (a -> b -> c -> d -> e -> result) -> Request a -> Request b -> Request c -> Request d -> Request e -> Request result

-- CHAINING REQUESTS

map : (a -> b) -> Request a -> Request b
andThen : (a -> Request b) -> Request a -> Request b
onError : (Error -> Request b) -> Request a -> Request b
succeed : a -> Request a
fail : String -> Request a

-- PROGRESS

type Loading a
noData : Loading a
progress : Loading a -> Request a -> Sub (Loading a)

-- DEBOUNCE

debounce : Int -> Request a -> Sub a

--}
