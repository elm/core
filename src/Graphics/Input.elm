module Graphics.Input
    ( button, customButton, checkbox, dropDown
    , hoverable, clickable
    ) where

{-| This module is for creating input widgets such as buttons and text fields.
All functions in this library report to a [`Signal.Mailbox`](Signal#message).

# Basic Input Elements

To learn about text fields, see the
[`Graphics.Input.Field`](Graphics-Input-Field) library.

@docs button, customButton, checkbox, dropDown

# Clicks and Hovers
@docs clickable, hoverable

-}

import Graphics.Element exposing (Element)
import Native.Graphics.Input
import Native.Text
import Signal


{-| Create a standard button. The following example begins making a basic
calculator:

    type Keys = Number Int | Plus | Minus | Clear

    keys : Signal.Mailbox Keys
    keys = Signal.mailbox Clear

    calculator : Element
    calculator =
        flow right
          [ button (Signal.message keys.address (Number 1)) "1"
          , button (Signal.message keys.address (Number 2)) "2"
          , button (Signal.message keys.address    Plus   ) "+"
          ]

If the user presses the "+" button, `keys.signal` will update to `Plus`. If the
users presses "2", `keys.signal` will update to `(Number 2)`.
-}
button : Signal.Message -> String -> Element
button =
  Native.Graphics.Input.button


{-| Same as `button` but lets you customize buttons to look however you want.

    click : Signal.Mailbox ()
    click = Signal.mailbox ()

    prettyButton : Element
    prettyButton =
        customButton (Signal.message click.address ())
            (image 100 40 "/button_up.jpg")
            (image 100 40 "/button_hover.jpg")
            (image 100 40 "/button_down.jpg")
-}
customButton : Signal.Message -> Element -> Element -> Element -> Element
customButton =
  Native.Graphics.Input.customButton


{-| Create a checkbox. The following example creates three synced checkboxes:

    check : Signal.Mailbox Bool
    check = Signal.mailbox False

    boxes : Bool -> Element
    boxes checked =
        let box = container 40 40 middle (checkbox (Signal.message check.address) checked)
        in
            flow right [ box, box, box ]

    main : Signal Element
    main = boxes <~ check.signal
-}
checkbox : (Bool -> Signal.Message) -> Bool -> Element
checkbox =
  Native.Graphics.Input.checkbox


{-| Create a drop-down menu.  The following drop-down lets you choose your
favorite British sport:

    type Sport = Football | Cricket | Snooker

    sport : Signal.Mailbox (Maybe Sport)
    sport = Signal.mailbox Nothing

    sportDropDown : Element
    sportDropDown =
        dropDown (Signal.message sport.address)
          [ (""        , Nothing)
          , ("Football", Just Football)
          , ("Cricket" , Just Cricket)
          , ("Snooker" , Just Snooker)
          ]

If the user selects "Football" from the drop down menu, `sport.signal`
will update to `Just Football`.
-}
dropDown : (a -> Signal.Message) -> List (String, a) -> Element
dropDown =
  Native.Graphics.Input.dropDown


{-| Detect mouse hovers over a specific `Element`. In the following example,
we will create a hoverable picture called `cat`.

    hover : Signal.Mailbox Bool
    hover = Signal.mailbox False

    cat : Element
    cat =
      image 30 30 "/cat.jpg"
        |> hoverable (Signal.message hover.address)

When the mouse hovers above the `cat` element, `hover.signal` will become
`True`. When the mouse leaves it, `hover.signal` will become `False`.
-}
hoverable : (Bool -> Signal.Message) -> Element -> Element
hoverable =
  Native.Graphics.Input.hoverable


{-| Detect mouse clicks on a specific `Element`. In the following example,
we will create a clickable picture called `cat`.

    type Picture = Cat | Hat

    picture : Signal.Mailbox Picture
    picture = Signal.mailbox Cat

    cat : Element
    cat =
      image 30 30 "/cat.jpg"
        |> clickable (Signal.message picture.address Cat)

    hat : Element
    hat =
      image 30 30 "/hat.jpg"
        |> clickable (Signal.message picture.address Hat)

When the user clicks on the `cat` element, `picture.signal` receives
an update containing the value `Cat`. When the user clicks on the `hat` element,
`picture.signal` receives an update containing the value `Hat`. This lets you
distinguish which element was clicked. In a more complex example, they could be
distinguished with IDs or more complex data structures.
-}
clickable : Signal.Message -> Element -> Element
clickable =
  Native.Graphics.Input.clickable
