module Port
    ( Port, InboundPort, OutboundPort
    , Address, Message
    , send, message, forward
    , sendResults
    ) where

import Native.Port
import Result exposing (Result)
import Stream exposing (Stream)
import Task exposing (Task, andThen, onError, succeed)


-- PORTS

{-| An `Port` is a communication hub. It is made up of

  * an `Address` that you can send messages to
  * a `Stream` of messages sent to the port

You set up ports with the `port` keyword:

    port numbers : Port Int
-}
type alias Port a =
    { address : Address a
    , stream : Stream a
    }


{-| An inbound port allows you to send messages from JavaScript into Elm. The
address is available in JavaScript, so we only have access to the corresponding
stream of messages. You set up an inbound port with the `port` keyword:

    port infoFromJavaScript : InboundPort String
-}
type alias InboundPort a =
    { stream : Stream a
    }


{-| An outbound port allows you to send messages from Elm to JavaScript. We
get access to an `Address` we can send messages to, and the corresponding
`Stream` is available in JavaScript. You set up an outbound port with the
`port` keyword:

    port messagesForJavaScript : OutboundPort String
-}
type alias OutboundPort a =
    { address : Address a
    }


-- ADDRESSES

type Address a =
    Address (a -> Task () ())


{-| Create an address that will forward all messages along.

    type Action = Undo | Remove Int

    port actions : Port Action

    removeAddress : Address Int
    removeAddress =
        forward Remove actions.address

In this case we have a general `address` that many people may send
messages to. The new `removeAddress` tags all messages with the `Remove` tag
before forwarding them along to the more general `address`. This means
some parts of our application can know *only* about `removeAddress` and not
care what other kinds of `Actions` are possible.
-}
forward : (a -> b) -> Address b -> Address a
forward f (Address send) =
    Address (\x -> send (f x))


type Message = Message (Task () ())


{-| Create a message that may be sent to a `Port` at a later time.

Most importantly, this lets us create APIs that can send values to ports
*without* allowing people to run arbitrary tasks.
-}
message : Address a -> a -> Message
message (Address send) value =
    Message (send value)


-- TALKING TO PORTS

{-| Send a message to an `Address`.

    type Action = Undo | Remove Int

    address : Address Action

    requestUndo : Task x ()
    requestUndo =
        send address Undo

The `Stream` associated with `address` will receive the `Undo` message
and push it through the Elm program.
-}
send : Address a -> a -> Task x ()
send (Address actuallySend) value =
    actuallySend value
      `onError` \_ -> succeed ()


sendResults : Address (Result x a) -> Stream (Task x a) -> Task y Task.ID
sendResults address stream =
    Task.subscribe stream (\task -> Task.toResult task `andThen` send address)
