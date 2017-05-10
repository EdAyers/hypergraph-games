module Ramsey exposing (..)

import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Html


type alias RamseyConfig =
    { n : Int
    , s : Int
    }


type alias RamseyAction =
    ( Int, Int )


type alias RamseyState =
    { n : Int
    , s : Int
    , moves : List ( Int, Int )
    }


type Player
    = P1
    | P2


toColour : Player -> String
toColour p =
    case p of
        P1 ->
            "blue"

        P2 ->
            "orange"


ramseyInit : RamseyConfig -> RamseyState
ramseyInit config =
    { n = config.n
    , s = config.s
    , moves = []
    }


circle : ( Float, Float ) -> Float -> List (Attribute msg) -> Svg msg
circle ( x, y ) radius ls =
    Svg.circle (List.append ls [ cx (toString x), cy (toString y), r (toString radius) ]) []


line : ( Float, Float ) -> ( Float, Float ) -> List (Attribute msg) -> Svg msg
line ( fx1, fy1 ) ( fx2, fy2 ) attrs =
    Svg.line (List.append attrs [ x1 (toString fx1), y1 (toString fy1), x2 (toString fx2), y2 (toString fy2) ]) []


label : ( Float, Float ) -> String -> Float -> List (Attribute msg) -> Svg msg
label ( fx, fy ) msg size attrs =
    Svg.text_ (x (toString fx) :: y (toString fy) :: fontSize (toString size) :: textAnchor "middle" :: dominantBaseline "middle" :: attrs) [ Svg.text msg ]


ramseyUpdate : RamseyAction -> RamseyState -> RamseyState
ramseyUpdate ( a, b ) state =
    let
        ( x, y ) =
            if a < b then
                ( a, b )
            else
                ( b, a )
    in
        if List.member ( x, y ) state.moves then
            state
        else if y > state.n || y <= 0 then
            state
        else
            { state | moves = ( x, y ) :: state.moves }


ramseyView : RamseyState -> Svg RamseyAction
ramseyView state =
    let
        range =
            List.range 1 state.n

        count =
            List.length state.moves

        vertPos i =
            let
                t =
                    2 * pi * (toFloat i) / (toFloat state.n)
            in
                ( cos (t), sin (t) )

        vertexView : Int -> Svg msg
        vertexView i =
            circle (vertPos i) 0.1 [ fill "darkgrey" ]

        verticesView =
            range |> List.map vertexView

        emptyLineView : ( Int, Int ) -> Svg RamseyAction
        emptyLineView ( a, b ) =
            line (vertPos a) (vertPos b) [ strokeWidth "0.05", onClick ( a, b ), stroke "lightgrey" ]

        moveView ( a, b ) player i =
            let
                ( ax, ay ) =
                    vertPos a

                ( bx, by ) =
                    vertPos b

                t =
                    if (b - a) % 2 == 0 then
                        0.8
                    else
                        0.2

                nx = ax - bx
                ny = ay - by
                nmag = sqrt (nx * nx + ny * ny)

                lx =
                    (ax * t + bx * (1.0 - t)) + (0.1 * -ny / nmag)

                ly =
                    (ay * t + by * (1.0 - t)) + (0.1 * nx / nmag)
            in
                Svg.g []
                    [ line (vertPos a) (vertPos b) [ strokeWidth "0.05", stroke (toColour player) ]
                    , label ( lx, ly ) (toString i) 0.1 [ fill "black" ]
                    ]

        allLines =
            range |> List.concatMap (\i -> List.range 1 (i - 1) |> List.map (\j -> ( j, i )))

        emptyLinesView =
            allLines
                |> List.filter (\pt -> not <| List.member pt state.moves)
                |> List.map emptyLineView

        fullLinesView =
            state.moves
                |> List.indexedMap
                    (\i e ->
                        moveView e
                            (if (count - i) % 2 == 0 then
                                P2
                             else
                                P1
                            )
                            (count - i)
                    )
    in
        Svg.g [] 
            (emptyLinesView
                ++ fullLinesView
                ++ verticesView
            )


places : List (Svg msg)
places =
    List.range -2 2 
    |> List.concatMap(\i -> List.range -2 2 |> List.map (\j -> (i,j)))
    |> List.map (\(i,j) -> label (toFloat i, toFloat j) (toString i ++ " , " ++ toString j ) 0.1 [])

svgFrame : Svg msg -> Html.Html msg
svgFrame svg =
    Svg.svg [ version "1.1", viewBox (" -1.5 -1.5 3 3") ] [svg]



main =
    Html.programWithFlags
        { view = ramseyView >> svgFrame
        , update = (\a m -> ( ramseyUpdate a m, Cmd.none))
        , init = \i -> (ramseyInit i, Cmd.none)
        , subscriptions = always Sub.none
        }
