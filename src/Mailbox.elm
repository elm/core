module Mailbox
    ( Mailbox
    , redirect
    , send
    ) where
{-| Mailboxes make it possible to send messages to a `WritableStream`. This
makes it possible for the outputs of your program to report back as an input
after some effects are performed.

# Send Messages
@docs send

# Redirect Messages
@docs redirect
-}

import Promise exposing (Promise, onError, succeed)


type Mailbox a =
    Mailbox (a -> Promise () ())


{-| Send a message to a mailbox.

    type Action = Undo | Remove Int

    actionMailbox : Mailbox Action

    requestUndo : Promise x ()
    requestUndo =
        send actionMailbox Undo

The `Stream` associated with `actionMailbox` will receive the `Undo` message
and push it through the Elm program.
-}
send : Mailbox a -> a -> Promise x ()
send (Mailbox actuallySend) value =
    actuallySend value
      `onError` \_ -> succeed ()


{-| Create a mailbox that will redirect all messages somewhere else.

    type Action = Undo | Remove Int

    actionMailbox : Mailbox Action

    removeMailbox : Mailbox Int
    removeMailbox =
        redirect Remove actionMailbox

In this case we have a general `actionMailbox` that many people may send
messages to. The `removeMailbox` is a redirect that tags all messages with
the `Remove` tag before sending them along to the more general `actionMailbox`.
This means some parts of our application can know *only* about `removeMailbox`
and not care what other kinds of `Actions` are possible.
-}
redirect : (b -> a) -> Mailbox a -> Mailbox b
redirect f (Mailbox send) =
    Mailbox (\x -> send (f x))