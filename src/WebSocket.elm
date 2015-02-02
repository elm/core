module WebSocket where
{-| A library for low latency HTTP communication. See the HTTP library for
standard requests like GET, POST, etc. The API of this library is likely to
change to make it more flexible.
-}

import Native.WebSocket
import JavaScript.Decode as JavaScript


-- url and protocols
connect : String -> List String -> Promise x Connection
connect =
  Native.WebSocket.connect


type alias Closed =
    { code : Int, reason : String, wasClean : Bool }


write : Connection -> String -> Promise Closed ()
write =
  Native.WebSocket.write


read : Connection -> Promise Closed JavaScript.Value
read =
  Native.WebSocket.read


close : Connection -> Promise x ()
close =
  Native.WebSocket.close


closeWith : { code : Int, reason : String } -> Connection -> Promise x ()
closeWith =
  Native.WebSocket.closeWith