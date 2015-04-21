module Signal
    ( Signal
    , merge, mergeMany
    , map, map2, map3, map4, map5
    , (<~), (~)
    , constant
    , dropRepeats, filter, filterMap, sampleOn
    , foldp
    , Mailbox, Address, Message
    , mailbox, send, message, forwardTo
    ) where

{-| A *signal* is a value that changes over time. For example, we can
think of the mouse position as a pair of numbers that is changing over time,
whenever the user moves the mouse.

    Mouse.position : Signal (Int,Int)

Another signal is the `Element` or `Html` we want to show on screen.

    main : Signal Html

As the `Html` changes, the user sees different things on screen automatically.

Some useful functions for working with time (e.g. setting FPS) and combining
signals and time (e.g. timestamps) can be found in the [`Time`](Time) library.

# Merging
@docs merge, mergeMany

# Mapping
@docs map, map2, map3, map4, map5

# Fancy Mapping
@docs (<~), (~)

# Past-Dependence
@docs foldp

# Filters
@docs filter, filterMap, dropRepeats, sampleOn

# Mailboxes
@docs Mailbox, mailbox, message, forwardTo, send

# Constants
@docs constant

-}


import Basics exposing (fst, snd, not, always)
import Debug
import List
import Maybe exposing (Maybe(Just,Nothing))
import Native.Signal
import Task exposing (Task, succeed, onError)


type Signal a = Signal


{-| Create a signal that never changes. This can be useful if you need
to pass a combination of signals and normal values to a function:

    map3 view Window.dimensions Mouse.position (constant initialModel)
-}
constant : a -> Signal a
constant =
  Native.Signal.constant


{-| Apply a function to a signal.

    mouseIsUp : Signal Bool
    mouseIsUp =
        map not Mouse.isDown

    main : Signal Element
    main =
        map toElement Mouse.position
-}
map : (a -> result) -> Signal a -> Signal result
map =
  Native.Signal.map


{-| Apply a function to the current value of two signals. The function
is reevaluated whenever *either* signal changes. In the following example, we
figure out the `aspectRatio` of the window by combining the current width and
height.

    ratio : Int -> Int -> Float
    ratio width height =
        toFloat width / toFloat height

    aspectRatio : Signal Float
    aspectRatio =
        map2 ratio Window.width Window.height
-}
map2 : (a -> b -> result) -> Signal a -> Signal b -> Signal result
map2 =
  Native.Signal.map2


map3 : (a -> b -> c -> result) -> Signal a -> Signal b -> Signal c -> Signal result
map3 =
  Native.Signal.map3


map4 : (a -> b -> c -> d -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal result
map4 =
  Native.Signal.map4


map5 : (a -> b -> c -> d -> e -> result) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal result
map5 =
  Native.Signal.map5


{-| Create a past-dependent signal. Each update from the incoming signals will
be used to step the state forward. The outgoing signal represents the current
state.

    clickCount : Signal Int
    clickCount =
        foldp (\click total -> total + 1) 0 Mouse.clicks

    timeSoFar : Signal Time
    timeSoFar =
        foldp (+) 0 (fps 40)

So `clickCount` updates on each mouse click, incrementing by one. `timeSoFar`
is the time the program has been running, updated 40 times a second.
-}
foldp : (a -> state -> state) -> state -> Signal a -> Signal state
foldp =
    Native.Signal.foldp


{-| Merge two signals into one. This function is extremely useful for bringing
together lots of different signals to feed into a `foldp`.

    type Update = MouseMove (Int,Int) | TimeDelta Float

    updates : Signal Update
    updates =
        merge
            (map MouseMove Mouse.position)
            (map TimeDelta (fps 40))

If an update comes from either of the incoming signals, it updates the outgoing
signal. If an update comes on both signals at the same time, the left update
wins (i.e., the right update is discarded).
-}
merge : Signal a -> Signal a -> Signal a
merge left right =
    Native.Signal.genericMerge always left right


{-| Merge many signals into one. This is useful when you are merging more than
two signals. When multiple updates come in at the same time, the left-most
update wins, just like with `merge`.

    type Update = MouseMove (Int,Int) | TimeDelta Float | Click

    updates : Signal Update
    updates =
        mergeMany
            [ map MouseMove Mouse.position
            , map TimeDelta (fps 40)
            , map (always Click) Mouse.clicks
            ]
-}
mergeMany : List (Signal a) -> Signal a
mergeMany signalList =
  case List.reverse signalList of
    [] ->
        Debug.crash "mergeMany was given an empty list!"

    signal :: signals ->
        List.foldl merge signal signals


{-| Filter out some updates. The given function decides whether we should
*keep* an update. If no updates ever flow through, we use the default value
provided. The following example only keeps even numbers and has an initial
value of zero.

    numbers : Signal Int

    isEven : Int -> Bool

    evens : Signal Int
    evens =
        filter isEven 0 numbers
-}
filter : (a -> Bool) -> a -> Signal a -> Signal a
filter isOk base signal =
    filterMap (\value -> if isOk value then Just value else Nothing) base signal


{-| Filter out some updates. When the filter function gives back `Just` a
value, we send that value along. When it returns `Nothing` we drop it.
If the initial value of the incoming signal turns into `Nothing`, we use the
default value provided. The following example keeps only strings that can be
read as integers.

    userInput : Signal String

    toInt : String -> Maybe Int

    numbers : Signal Int
    numbers =
        filterMap toInt 0 userInput
-}
filterMap : (a -> Maybe b) -> b -> Signal a -> Signal b
filterMap =
    Native.Signal.filterMap


{-| Drop updates that repeat the current value of the signal.

    numbers : Signal Int

    noDups : Signal Int
    noDups =
        dropRepeats numbers

    --  numbers => 0 0 3 3 5 5 5 4 ...
    --  noDups  => 0   3   5     4 ...

The signal should not be a signal of functions, or a record that contains a
function (you'll get a runtime error since functions cannot be equated).
-}
dropRepeats : Signal a -> Signal a
dropRepeats =
    Native.Signal.dropRepeats


{-| Sample from the second input every time an event occurs on the first input.
For example, `(sampleOn Mouse.clicks (Time.every Time.second))` will give the
approximate time of the latest click. -}
sampleOn : Signal a -> Signal b -> Signal b
sampleOn =
    Native.Signal.sampleOn


{-| An alias for `map`. A prettier way to apply a function to the current value
of a signal.

    main : Signal Html
    main =
      view <~ model

    model : Signal Model

    view : Model -> Html
-}
(<~) : (a -> b) -> Signal a -> Signal b
(<~) =
  map


{-| Intended to be paired with the `(<~)` operator, this makes it possible for
many signals to flow into a function. Think of it as a fancy alias for
`mapN`. For example, the following declarations are equivalent:

    main : Signal Element
    main =
      scene <~ Window.dimensions ~ Mouse.position

    main : Signal Element
    main =
      map2 scene Window.dimensions Mouse.position

You can use this pattern for as many signals as you want by using `(~)` a bunch
of times, so you can go higher than `map5` if you need to.
-}
(~) : Signal (a -> b) -> Signal a -> Signal b
(~) funcs args =
  map2 (\f v -> f v) funcs args


infixl 4 <~
infixl 4 ~



-- MAILBOXES

{-| An `Mailbox` is a communication hub. It is made up of

  * an `Address` that you can send messages to
  * a `Signal` of messages sent to the mailbox
-}
type alias Mailbox a =
    { address : Address a
    , signal : Signal a
    }


type Address a =
    Address (a -> Task () ())



{-| Create a mailbox you can send messages to. The primary use case is
receiving updates from tasks and UI elements. The argument is a default value
for the custom signal.

Note: Creating new signals is inherently impure, so `(mailbox ())` and
`(mailbox ())` produce two different mailboxes.
-}
mailbox : a -> Mailbox a
mailbox =
  Native.Signal.mailbox


{-| Create a new address. This address will will tag each message it receives
and then forward it along to some other address.

    type Action = Undo | Remove Int

    port actions : Mailbox Action

    removeAddress : Address Int
    removeAddress =
        forwardTo actions.address Remove

In this case we have a general `address` that many people may send
messages to. The new `removeAddress` tags all messages with the `Remove` tag
before forwarding them along to the more general `address`. This means
some parts of our application can know *only* about `removeAddress` and not
care what other kinds of `Actions` are possible.
-}
forwardTo : Address b -> (a -> b) -> Address a
forwardTo (Address send) f =
    Address (\x -> send (f x))


type Message = Message (Task () ())


{-| Create a message that may be sent to a `Mailbox` at a later time.

Most importantly, this lets us create APIs that can send values to ports
*without* allowing people to run arbitrary tasks.
-}
message : Address a -> a -> Message
message (Address send) value =
    Message (send value)


{-| Send a message to an `Address`.

    type Action = Undo | Remove Int

    address : Address Action

    requestUndo : Task x ()
    requestUndo =
        send address Undo

The `Signal` associated with `address` will receive the `Undo` message
and push it through the Elm program.
-}
send : Address a -> a -> Task x ()
send (Address actuallySend) value =
    actuallySend value
      `onError` \_ -> succeed ()
