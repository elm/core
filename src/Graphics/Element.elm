module Graphics.Element
    ( Element
    , image, fittedImage, croppedImage, tiledImage
    , leftAligned, rightAligned, centered, justified, show
    , width, height, size, color, opacity, link, tag
    , widthOf, heightOf, sizeOf
    , flow, Direction, up, down, left, right, inward, outward
    , layers, above, below, beside
    , empty, spacer, container
    , middle, midTop, midBottom, midLeft, midRight, topLeft, topRight
    , bottomLeft, bottomRight
    , Pos, Position
    , absolute, relative, middleAt, midTopAt, midBottomAt, midLeftAt
    , midRightAt, topLeftAt, topRightAt, bottomLeftAt, bottomRightAt
    ) where

{-| Graphical elements that snap together to build complex widgets and layouts.
Each Element is a rectangle with a known width and height, making them easy to
combine and position.

# Elements
@docs Element

# Show Anything
@docs show

# Images
@docs image, fittedImage, croppedImage, tiledImage

# Text
Each of the following functions places [`Text`](Text) into a box. The function
you use determines the alignment of the text.

@docs leftAligned, rightAligned, centered, justified

# Styling
@docs width, height, size, color, opacity, link, tag

# Inspection
@docs widthOf, heightOf, sizeOf

# Layout
@docs flow, Direction, up, down, left, right, inward, outward

## Layout Aliases
There are also some convenience functions for working
with `flow` in specific cases:

@docs layers, above, below, beside

# Positioning
@docs empty, spacer, container

## Specific Positions

@docs Position, middle, midTop, midBottom, midLeft, midRight, topLeft,
  topRight, bottomLeft, bottomRight

If you need more precision, you can create custom positions.

@docs Pos, absolute, relative, middleAt, midTopAt, midBottomAt, midLeftAt,
      midRightAt, topLeftAt, topRightAt, bottomLeftAt, bottomRightAt
-}

import Basics exposing (..)
import Color exposing (..)
import List as List
import Maybe exposing ( Maybe(..), withDefault )
import Native.Graphics.Element
import Text exposing (Text)


-- PRIMITIVES

{-| A graphical element that can be rendered on screen. Every element is a
rectangle with a known width and height, so they can be composed and stacked
easily.
-}
type Element =
  Element_elm_builtin
    { props : Properties
    , element : ElementPrim
    }


type alias Properties =
    { id      : Int
    , width   : Int
    , height  : Int
    , opacity : Float
    , color   : Maybe Color
    , href    : String
    , tag     : String
    , hover   : ()
    , click   : ()
    }


{-| An Element that takes up no space. Good for things that appear conditionally:

    flow down [ img1, if showMore then img2 else empty ]
-}
empty : Element
empty =
    spacer 0 0


{-| Get the width of an Element -}
widthOf : Element -> Int
widthOf (Element_elm_builtin e) =
    e.props.width


{-| Get the height of an Element -}
heightOf : Element -> Int
heightOf (Element_elm_builtin e) =
    e.props.height


{-| Get the width and height of an Element -}
sizeOf : Element -> (Int,Int)
sizeOf (Element_elm_builtin e) =
    (e.props.width, e.props.height)


{-| Create an `Element` with a given width. -}
width : Int -> Element -> Element
width newWidth (Element_elm_builtin {element, props}) =
  let
    newHeight =
      case element of
        Image _ w h _ ->
            round (toFloat h / toFloat w * toFloat newWidth)

        RawHtml ->
            snd (Native.Graphics.Element.htmlHeight newWidth element)

        _ ->
            props.height
  in
    Element_elm_builtin
      { element = element
      , props = { props | width = newWidth, height = newHeight }
      }


{-| Create an `Element` with a given height. -}
height : Int -> Element -> Element
height newHeight (Element_elm_builtin {element, props}) =
  Element_elm_builtin
    { element = element
    , props = { props | height = newHeight }
    }


{-| Create an `Element` with a new width and height. -}
size : Int -> Int -> Element -> Element
size w h e =
    height h (width w e)


{-| Create an `Element` with a given opacity. Opacity is a number between 0 and 1
where 0 means totally clear.
-}
opacity : Float -> Element -> Element
opacity givenOpacity (Element_elm_builtin {element, props}) =
  Element_elm_builtin
    { element = element
    , props = { props | opacity = givenOpacity }
    }


{-| Create an `Element` with a given background color. -}
color : Color -> Element -> Element
color clr (Element_elm_builtin {element, props}) =
  Element_elm_builtin
    { element = element
    , props = { props | color = Just clr }
    }


{-| Create an `Element` with a tag. This lets you link directly to it.
The element `(tag "all-about-badgers" thirdParagraph)` can be reached
with a link like this: `/facts-about-animals.elm#all-about-badgers`
-}
tag : String -> Element -> Element
tag name (Element_elm_builtin {element, props}) =
  Element_elm_builtin
    { element = element
    , props = { props | tag = name }
    }


{-| Create an `Element` that is a hyper-link. -}
link : String -> Element -> Element
link href (Element_elm_builtin {element, props}) =
  Element_elm_builtin
    { element = element
    , props = { props | href = href }
    }


newElement : Int -> Int -> ElementPrim -> Element
newElement =
    Native.Graphics.Element.newElement


type ElementPrim
    = Image ImageStyle Int Int String
    | Container RawPosition Element
    | Flow Direction (List Element)
    | Spacer
    | RawHtml
    | Custom -- for custom Elements implemented in JS, see collage for example


-- IMAGES

type ImageStyle = Plain | Fitted | Cropped (Int,Int) | Tiled


{-| Create an image given a width, height, and image source. -}
image : Int -> Int -> String -> Element
image w h src =
    newElement w h (Image Plain w h src)


{-| Create a fitted image given a width, height, and image source.
This will crop the picture to best fill the given dimensions.
-}
fittedImage : Int -> Int -> String -> Element
fittedImage w h src =
    newElement w h (Image Fitted w h src)


{-| Create a cropped image. Take a rectangle out of the picture starting
at the given top left coordinate. If you have a 140-by-140 image,
the following will cut a 100-by-100 square out of the middle of it.

    croppedImage (20,20) 100 100 "yogi.jpg"
-}
croppedImage : (Int,Int) -> Int -> Int -> String -> Element
croppedImage pos w h src =
    newElement w h (Image (Cropped pos) w h src)


{-| Create a tiled image. Repeat the image to fill the given width and height.

    tiledImage 100 100 "yogi.jpg"
-}
tiledImage : Int -> Int -> String -> Element
tiledImage w h src =
    newElement w h (Image Tiled w h src)


-- TEXT

{-| Align text along the left side of the text block. This is sometimes known as
*ragged right*.
-}
leftAligned : Text -> Element
leftAligned =
    Native.Graphics.Element.block "left"


{-| Align text along the right side of the text block. This is sometimes known
as *ragged left*.
-}
rightAligned : Text -> Element
rightAligned =
    Native.Graphics.Element.block "right"


{-| Center text in the text block. There is equal spacing on either side of a
line of text.
-}
centered : Text -> Element
centered =
    Native.Graphics.Element.block "center"


{-| Align text along the left and right sides of the text block. Word spacing is
adjusted to make this possible.
-}
justified : Text -> Element
justified =
    Native.Graphics.Element.block "justify"


{-| Convert anything to its textual representation and make it displayable in
the browser. Excellent for debugging.

    main : Element
    main =
      show "Hello World!"

    show value =
        leftAligned (Text.monospace (Text.fromString (toString value)))
-}
show : a -> Element
show value =
    leftAligned (Text.monospace (Text.fromString (toString value)))


-- LAYOUT

type Three = P | Z | N


{-| Specifies a distance from a particular location within a `container`, like
“20 pixels right and up from the center”. You can use `absolute` or `relative`
to specify a `Pos` in pixels or as a percentage of the container.
-}
type Pos
    = Absolute Int
    | Relative Float


{-| Specifies a position for an element within a `container`, like “the top
left corner”.
-}
type Position = Position RawPosition


type alias RawPosition =
    { horizontal : Three
    , vertical : Three
    , x : Pos
    , y : Pos
    }


{-| Put an element in a container. This lets you position the element really
easily, and there are tons of ways to set the `Position`.
To center `element` exactly in a 300-by-300 square you would say:

    container 300 300 middle element

By setting the color of the container, you can create borders.
-}
container : Int -> Int -> Position -> Element -> Element
container w h (Position rawPos) e =
    newElement w h (Container rawPos e)


{-| Create an empty box. This is useful for getting your spacing right and
for making borders.
-}
spacer : Int -> Int -> Element
spacer w h =
    newElement w h Spacer


{-| Represents a `flow` direction for a list of elements.
-}
type Direction = DUp | DDown | DLeft | DRight | DIn | DOut


{-| Have a list of elements flow in a particular direction.
The `Direction` starts from the first element in the list.

    flow right [a,b,c]

        +---+---+---+
        | a | b | c |
        +---+---+---+
-}
flow : Direction -> List Element -> Element
flow dir es =
  let ws = List.map widthOf es
      hs = List.map heightOf es
      maxOrZero list = withDefault 0 (List.maximum list)
      newFlow w h = newElement w h (Flow dir es)
  in
  if es == [] then empty else
  case dir of
    DUp    -> newFlow (maxOrZero ws) (List.sum hs)
    DDown  -> newFlow (maxOrZero ws) (List.sum hs)
    DLeft  -> newFlow (List.sum ws) (maxOrZero hs)
    DRight -> newFlow (List.sum ws) (maxOrZero hs)
    DIn    -> newFlow (maxOrZero ws) (maxOrZero hs)
    DOut   -> newFlow (maxOrZero ws) (maxOrZero hs)


{-| Stack elements vertically.
To put `a` above `b` you would say: ``a `above` b``
-}
above : Element -> Element -> Element
above hi lo =
    newElement
        (max (widthOf hi) (widthOf lo))
        (heightOf hi + heightOf lo)
        (Flow DDown [hi,lo])


{-| Stack elements vertically.
To put `a` below `b` you would say: ``a `below` b``
-}
below : Element -> Element -> Element
below lo hi =
    newElement
        (max (widthOf hi) (widthOf lo))
        (heightOf hi + heightOf lo)
        (Flow DDown [hi,lo])


{-| Put elements beside each other horizontally.
To put `a` beside `b` you would say: ``a `beside` b``
-}
beside : Element -> Element -> Element
beside lft rht =
    newElement
        (widthOf lft + widthOf rht)
        (max (heightOf lft) (heightOf rht))
        (Flow right [lft,rht])


{-| Layer elements on top of each other, starting from the bottom:
`layers == flow outward`
-}
layers : List Element -> Element
layers es =
  let ws = List.map widthOf es
      hs = List.map heightOf es
  in
      newElement
          (withDefault 0 (List.maximum ws))
          (withDefault 0 (List.maximum hs))
          (Flow DOut es)


-- Repetitive things --

{-| A position specified in pixels. If you want something 10 pixels to the
right of the middle of a container, you would write this:

    middleAt (absolute 10) (absolute 0)

-}
absolute : Int -> Pos
absolute =
  Absolute


{-| A position specified as a percentage. If you want something 10% away from
the top left corner, you would say:

    topLeftAt (relative 0.1) (relative 0.1)
-}
relative : Float -> Pos
relative =
  Relative


{-|-}
middle : Position
middle =
  Position { horizontal = Z, vertical = Z, x = Relative 0.5, y = Relative 0.5 }


{-|-}
topLeft : Position
topLeft =
  Position { horizontal = N, vertical = P, x = Absolute 0, y = Absolute 0 }


{-|-}
topRight : Position
topRight =
  Position { horizontal = P, vertical = P, x = Absolute 0, y = Absolute 0 }


{-|-}
bottomLeft : Position
bottomLeft =
  Position { horizontal = N, vertical = N, x = Absolute 0, y = Absolute 0 }


{-|-}
bottomRight : Position
bottomRight =
  Position { horizontal = P, vertical = N, x = Absolute 0, y = Absolute 0 }


{-|-}
midLeft : Position
midLeft =
  Position { horizontal = N, vertical = Z, x = Absolute 0, y = Relative 0.5 }


{-|-}
midRight : Position
midRight =
  Position { horizontal = P, vertical = Z, x = Absolute 0, y = Relative 0.5 }


{-|-}
midTop : Position
midTop =
  Position { horizontal = Z, vertical = P, x = Relative 0.5, y = Absolute 0 }


{-|-}
midBottom : Position
midBottom =
  Position { horizontal = Z, vertical = N, x = Relative 0.5, y = Absolute 0 }


{-|-}
middleAt : Pos -> Pos -> Position
middleAt x y =
  Position { horizontal = Z, vertical = Z, x = x, y = y }


{-|-}
topLeftAt : Pos -> Pos -> Position
topLeftAt x y =
  Position { horizontal = N, vertical = P, x = x, y = y }


{-|-}
topRightAt : Pos -> Pos -> Position
topRightAt x y =
  Position { horizontal = P, vertical = P, x = x, y = y }


{-|-}
bottomLeftAt : Pos -> Pos -> Position
bottomLeftAt x y =
  Position { horizontal = N, vertical = N, x = x, y = y }


{-|-}
bottomRightAt : Pos -> Pos -> Position
bottomRightAt x y =
  Position { horizontal = P, vertical = N, x = x, y = y }


{-|-}
midLeftAt : Pos -> Pos -> Position
midLeftAt x y =
  Position { horizontal = N, vertical = Z, x = x, y = y }


{-|-}
midRightAt : Pos -> Pos -> Position
midRightAt x y =
  Position { horizontal = P, vertical = Z, x = x, y = y }


{-|-}
midTopAt : Pos -> Pos -> Position
midTopAt x y =
  Position { horizontal = Z, vertical = P, x = x, y = y }


{-|-}
midBottomAt : Pos -> Pos -> Position
midBottomAt x y =
  Position { horizontal = Z, vertical = N, x = x, y = y }


{-|-}
up : Direction
up =
  DUp


{-|-}
down : Direction
down =
  DDown


{-|-}
left : Direction
left =
  DLeft


{-|-}
right : Direction
right =
  DRight


{-|-}
inward : Direction
inward =
  DIn


{-|-}
outward : Direction
outward =
  DOut
