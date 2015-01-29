module Http where

import Native.Http


{-| Send a fully customizable request. Arguments are:

  * verb - GET, POST, PUT, etc.
  * headers - list of HTTP headers
  * url - where you want to send the request
  * body - the body of the HTTP message
  * mimeType - override the MIME type returned by the server
  * decoder - turn the response into an Elm value
-}
send : String -> List (String,String) -> String -> String -> Maybe String -> Json.Decoder a -> Promise Error a
send =
  Native.Http.send

-- TODO: deal with getAllResponseHeaders in `send`



{-| Send a GET request to the given url. You also specify how to decode the
response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      get (list string) "http://example.com/hat-categories.json"

-}
get : Json.Decoder a -> String -> Promise Error a
get decoder url =
  send "GET" [] decoder url Nothing


{-| Send a POST send to the given url, carrying the given string as the body.
You also specify how to decode the response.

    import JavaScript.Decode (list, string)

    hats : Promise Error (List String)
    hats =
      post (list string) "http://example.com/hat-categories.json" ""

-}
post : Json.Decoder a -> String -> String -> Promise Error a
post url body =
  send "POST" url body []