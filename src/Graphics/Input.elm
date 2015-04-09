module Graphics.Input where
{-| This module is for creating input widgets such as buttons and text fields.
All functions in this library report to a [`Signal.Channel`](Signal#send).

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

    keys : Signal.Channel Keys
    keys = Signal.channel Clear

    calculator : Element
    calculator =
        flow right
          [ button (Signal.send keys (Number 1)) "1"
          , button (Signal.send keys (Number 2)) "2"
          , button (Signal.send keys    Plus   ) "+"
          ]

If the user presses the "+" button, `keys.signal` will update to `Plus`. If the
users presses "2", `keys.signal` will update to `(Number 2)`.
-}
button : Signal.Message -> String -> Element
button =
  Native.Graphics.Input.button


{-| Same as `button` but lets you customize buttons to look however you want.

    click : Signal.Channel ()
    click = Signal.channel ()

    prettyButton : Element
    prettyButton =
        customButton (Signal.send click ())
            (image 100 40 "/button_up.jpg")
            (image 100 40 "/button_hover.jpg")
            (image 100 40 "/button_down.jpg")
-}
customButton : Signal.Message -> Element -> Element -> Element -> Element
customButton =
  Native.Graphics.Input.customButton


{-| Create a checkbox. The following example creates three synced checkboxes:

    check : Signal.Channel Bool
    check = Signal.channel False

    boxes : Bool -> Element
    boxes checked =
        let box = container 40 40 middle (checkbox (Signal.send check) checked)
        in
            flow right [ box, box, box ]

    main : Signal Element
    main = boxes <~ Signal.subscribe check
-}
checkbox : (Bool -> Signal.Message) -> Bool -> Element
checkbox =
  Native.Graphics.Input.checkbox


{-| Create a drop-down menu.  The following drop-down lets you choose your
favorite British sport:

    type Sport = Football | Cricket | Snooker

    sport : Signal.Channel (Maybe Sport)
    sport = Signal.channel Nothing

    sportDropDown : Element
    sportDropDown =
        dropDown (Signal.send sport)
          [ (""        , Nothing)
          , ("Football", Just Football)
          , ("Cricket" , Just Cricket)
          , ("Snooker" , Just Snooker)
          ]

If the user selects "Football" from the drop down menue, `Signal.subscribe sport`
will update to `Just Football`.
-}
dropDown : (a -> Signal.Message) -> List (String, a) -> Element
dropDown =
  Native.Graphics.Input.dropDown


{-| Detect mouse hovers over a specific `Element`. In the following example,
we will create a hoverable picture called `cat`.

    hover : Signal.Channel Bool
    hover = Signal.channel False

    cat : Element
    cat =
      image 30 30 "/cat.jpg"
        |> hoverable (Signal.send hover)

When the mouse hovers above the `cat` element, `hover.signal` will become
`True`. When the mouse leaves it, `hover.signal` will become `False`.
-}
hoverable : (Bool -> Signal.Message) -> Element -> Element
hoverable =
  Native.Graphics.Input.hoverable


{-| Detect mouse clicks on a specific `Element`. In the following example,
we will create a clickable picture called `cat`.

    type Picture = Cat | Hat

    picture : Signal.Channel Picture
    picture = Signal.channel Cat

    cat : Element
    cat =
      image 30 30 "/cat.jpg"
        |> clickable (Signal.send picture Cat)

    hat : Element
    hat =
      image 30 30 "/hat.jpg"
        |> clickable (Signal.send picture Hat)

When the user clicks on the `cat` element, `picture.signal` receives
an update containing the value `Cat`. When the user clicks on the `hat` element,
`picture.signal` receives an update containing the value `Hat`. This lets you
distinguish which element was clicked. In a more complex example, they could be
distinguished with IDs or more complex data structures.
-}
clickable : Signal.Message -> Element -> Element
clickable =
  Native.Graphics.Input.clickable
