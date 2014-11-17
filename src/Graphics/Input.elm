module Graphics.Input where
{-| This module is for creating input widgets such as buttons and text fields.
All functions in this library report to a [`Signal.Input`](Signal#customSignal).

# Basic Input Elements

To learn about text fields, see the
[`Graphics.Input.Field`](Graphics-Input-Field) library.

@docs button, customButton, checkbox, dropDown

# Clicks and Hovers
@docs clickable, hoverable

-}

import Signal
import Graphics.Element (Element)
import Native.Graphics.Input


{-| Create a standard button. The following example begins making a basic
calculator:

      data Keys = Number Int | Plus | Minus | Clear

      keys : Input Keys
      keys = input Clear

      calculator : Element
      calculator =
          flow right [ button keys.handle (Number 1) "1"
                     , button keys.handle (Number 2) "2"
                     , button keys.handle    Plus    "+"
                     ]

If the user presses the "+" button, `keys.signal` will update to `Plus`. If the
users presses "2", `keys.signal` will update to `(Number 2)`.
-}
button : Signal.Message -> String -> Element
button = Native.Graphics.Input.button

{-| Same as `button` but lets you customize buttons to look however you want.

      click : Input ()
      click = input ()

      prettyButton : Element
      prettyButton =
          customButton click.handle ()
              (image 100 40 "/button_up.jpg")
              (image 100 40 "/button_hover.jpg")
              (image 100 40 "/button_down.jpg")
-}
customButton : Signal.Message -> Element -> Element -> Element -> Element
customButton = Native.Graphics.Input.customButton

{-| Create a checkbox. The following example creates three synced checkboxes:

      check : Input Bool
      check = input False

      boxes : Bool -> Element
      boxes checked =
          let box = container 40 40 middle (checkbox check.handle identity checked)
          in  flow right [ box, box, box ]

      main : Signal Element
      main = boxes <~ check.signal
-}
checkbox : (Bool -> Signal.Message) -> Bool -> Element
checkbox = Native.Graphics.Input.checkbox

{-| Create a drop-down menu.  The following drop-down lets you choose your
favorite British sport:

      data Sport = Football | Cricket | Snooker

      sport : Input (Maybe Sport)
      sport = input Nothing

      sportDropDown : Element
      sportDropDown =
          dropDown sport.handle
            [ (""        , Nothing)
            , ("Football", Just Football)
            , ("Cricket" , Just Cricket)
            , ("Snooker" , Just Snooker)
            ]

If the user selects "Football" from the drop down menue, `sport.signal`
will update to `Just Football`.
-}
dropDown : List (String, Signal.Message) -> Element
dropDown = Native.Graphics.Input.dropDown

{-| Detect mouse hovers over a specific `Element`. In the following example,
we will create a hoverable picture called `cat`.

      hover : Input Bool
      hover = input False

      cat : Element
      cat = image 30 30 "/cat.jpg"
              |> hoverable hover.handle id

When the mouse hovers above the `cat` element, `hover.signal` will become
`True`. When the mouse leaves it, `hover.signal` will become `False`.
-}
hoverable : (Bool -> Signal.Message) -> Element -> Element
hoverable = Native.Graphics.Input.hoverable

{-| Detect mouse clicks on a specific `Element`. In the following example,
we will create a clickable picture called `cat`.

      data Picture = Cat | Hat

      picture : Input Picture
      picture = input Cat

      cat : Element
      cat = image 30 30 "/cat.jpg"
               |> clickable picture.handle Cat

      hat : Element
      hat = image 30 30 "/hat.jpg"
               |> clickable picture.handle Hat

When the user clicks on the `cat` element, `picture.signal` receives
an update containing the value `Cat`. When the user clicks on the `hat` element,
`picture.signal` receives an update containing the value `Hat`. This lets you
distinguish which element was clicked. In a more complex example, they could be
distinguished with IDs or more complex data structures.
-}
clickable : Signal.Message -> Element -> Element
clickable = Native.Graphics.Input.clickable
