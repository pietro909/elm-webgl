import Math.Vector2 as V2
import Math.Vector3 exposing (..)
import Math.Matrix4 exposing (..)
import WebGL exposing (..)
import Html exposing (Html)
import Html.App as Html
import Html.Attributes exposing (width, height)
import Html exposing (div, text, p)
import AnimationFrame


main : Program Never
main =
  Html.program
    { init = (0, Cmd.none)
    , view = view
    , subscriptions = (\model -> AnimationFrame.diffs Basics.identity)
    , update = (\elapsed currentTime -> (elapsed + currentTime, Cmd.none))
    }


type alias Vertex = { position : Vec3, color : Vec3 }

type alias Model =
  { sides : Int
  , radius : Float
  , color : Vec3
  , mesh : Drawable Vertex
  }

type Msg
  = Sides Int
  | Radius Float
  | Color Vec3


update : Model -> Msg -> Model
update model msg =
  case msg of
    Sides sides ->
      let
        drawable = ngon (V2.vec2 0 0) sides model.radius model.color
      in
        { model | sides = sides, mesh = drawable }
    Radius radius ->
      let
        drawable = ngon (V2.vec2 0 0) model.sides radius model.color
      in
        { model | radius = radius, mesh = drawable }


view : Model -> Html a
view model =
  article []
    [ aside []
      [ div []
        [ label [] [ text "Sides" ]
        , input [ type' "number", min 3, max 16, step 1, value model.sides, onInput Sides ] []
        ]
      , div []
        [ label [] [ text "Radius" ]
        , input [ type' "number", min 0.1, max 1.0, step 0.01, value model.radius, onInput Radius ] []
        ]
      ]
    , section []
      [ WebGL.toHtml
        [ width 400, height 400 ]
        [ WebGL.render vertexShader fragmentShader model.mesh { } ]
      ]
    ]


nextNGonPoint : Float -> Int -> List V2.Vec2 -> List V2.Vec2
nextNGonPoint alpha current acc =
  let
    x = cos (alpha * (toFloat current))
    y = sin (alpha * (toFloat current))
    vertex = V2.vec2 x y
    next = current - 1
  in
    if current == 0 then
      vertex::acc
    else
      nextNGonPoint alpha next (vertex::acc)

ngon : V2.Vec2 -> Int -> Float -> Vec3 -> Drawable Vertex
ngon position sides radius color =
  let
    alpha : Float
    alpha = (pi * 2.0 / (toFloat sides)) --+ (pi/4.0)
    vertices = nextNGonPoint alpha (sides - 1) []
    vec2ToVertex = (\v -> 
      { position = vec3 (V2.getX v) (V2.getY v) 0, color = color }
    )
  in
    List.map vec2ToVertex vertices
      |> TriangleFan
    

 


-- SHADERS

vertexShader :
  Shader
  { attr | position: Vec3, color: Vec3 }
  { }
  { vcolor:Vec3 }
vertexShader = [glsl|

attribute vec3 position;
attribute vec3 color;
varying vec3 vcolor;

void main () {
    gl_Position = vec4(position, 1.0);
    gl_PointSize = 4.0;
    vcolor = color;
}

|]


fragmentShader : Shader {} u { vcolor: Vec3 }
fragmentShader = [glsl|

precision mediump float;
varying vec3 vcolor;

void main () {
    gl_FragColor = vec4(vcolor, 1.0);
}

|]
