module WebSocket where

{-| A library for low latency HTTP communication. See the HTTP library for
standard requests like GET, POST, etc. The API of this library is likely to
change to make it more flexible.
-}

import Native.WebSocket
import JavaScript.Decoder as JavaScript


type alias Config =
    { url : String
    , protocols : List String
    }


connect : Config -> Promise Error Connection
connect =
  Native.WebSocket.connect


send : Connection -> String -> Promise Error ()
send =
  Native.WebSocket.send


type Event
    = Message JavaScript.Value
    | Close { code : Int, reason : String, wasClean : Bool }


listen : Connection -> (Event -> Promise x a) -> Promise x a
listen =
  Native.WebSocket.listen


close : Connection -> Promise x ()
close =
  Native.WebSocket.close


closeWith : Int -> String -> Connection -> Promise x ()
closeWith =
  Native.WebSocket.closeWith