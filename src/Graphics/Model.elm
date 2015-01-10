module Graphics.Model where

import Color (Color, Gradient)
import Maybe (Maybe)
import Transform2D (Transform2D)

type alias Form =
    { theta : Float
    , scale : Float
    , x : Float
    , y : Float
    , alpha : Float
    , form : BasicForm
    }

type BasicForm
    = FPath LineStyle Path
    | FShape ShapeStyle Shape
    | FImage Int Int (Int,Int) String
    | FElement Element
    | FGroup Transform2D (List Form)

type alias Path = List (Float,Float)

type alias Shape = List (Float,Float)

{-| The shape of the ends of a line. -}
type LineCap = Flat | Round | Padded

{-| The shape of the &ldquo;joints&rdquo; of a line, where each line segment
meets. `Sharp` takes an argument to limit the length of the joint. This
defaults to 10.
-}
type LineJoin = Smooth | Sharp Float | Clipped

{-| All of the attributes of a line style. This lets you build up a line style
however you want. You can also update existing line styles with record updates.
-}
type alias LineStyle =
    { color : Color
    , width : Float
    , cap   : LineCap
    , join  : LineJoin
    , dashing : List Int
    , dashOffset : Int
    }

type ShapeStyle
    = Line LineStyle
    | Fill FillStyle

type FillStyle
    = Solid Color
    | Texture String
    | Grad Gradient


type alias Element =
    { props : Properties
    , element : ElementPrim
    }

type alias Properties = {
  id      : Int,
  width   : Int,
  height  : Int,
  opacity : Float,
  color   : Maybe Color,
  href    : String,
  tag     : String,
  hover   : (),
  click   : ()
 }

type ElementPrim
    = Image ImageStyle Int Int String
    | Container Position Element
    | Flow Direction (List Element)
    | Spacer
    | RawHtml
    | Custom -- for custom Elements implemented in JS, see collage for example

type ImageStyle = Plain | Fitted | Cropped (Int,Int) | Tiled

type Three = P | Z | N

type Pos = Absolute Int | Relative Float

type alias Position =
    { horizontal : Three
    , vertical : Three
    , x : Pos
    , y : Pos
    }

type Direction = DUp | DDown | DLeft | DRight | DIn | DOut

