module Ramsey exposing (..)

import Svg exposing (Attribute, Svg)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onMouseDown, onMouseUp)
import Html
import Set exposing (Set)
import Mouse

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


ramseyWin : RamseyState -> Maybe ( Player, List ( Int, Int ) )
ramseyWin state =
    let
        count =
            state.moves |> List.length

        paintedMoves =
            state.moves
                |> List.indexedMap
                    (\i x ->
                        ( if (count - i) % 2 == 0 then
                            P2
                          else
                            P1
                        , x
                        )
                    )

        ( p1Moves, p2Moves ) =
            List.partition (Tuple.first >> (==) P1) paintedMoves

        isClique edges =
            let
                vcount =
                    List.foldl (\( a, b ) s -> s |> Set.insert a |> Set.insert b) Set.empty edges |> Set.size

                ecount =
                    edges |> List.length
            in
                (vcount) * (vcount - 1) // 2 == ecount

        grab k acc available =
            if k == 0 && isClique acc then
                Just acc
            else
                case available of
                    [] ->
                        Nothing

                    head :: tail ->
                        case grab (k - 1) (head :: acc) tail of
                            Just x ->
                                Just x

                            Nothing ->
                                grab k acc tail

        check player =
            paintedMoves
                |> List.filterMap
                    (\( p, pt ) ->
                        if p == player then
                            Just pt
                        else
                            Nothing
                    )
                |> grab (state.s * (state.s - 1) // 2) []
                |> Maybe.map (\acc -> ( player, acc ))

        elseThen x m =
            case m of
                Nothing ->
                    x ()

                Just y ->
                    Just y
    in
        check P1 |> elseThen (\() -> check P2)


ramseyView : State -> Svg Action
ramseyView state =
    let
        range =
            List.range 1 state.game.n

        count =
            List.length state.game.moves

        vertPos i =
            let
                t =
                    2 * pi * (toFloat i) / (toFloat state.game.n)
            in
                ( cos (t), sin (t) )

        eventer : Int -> Attribute Action
        eventer =
            case state.dragState of
            DragMoving _ _ _ -> \a -> onMouseUp (FinishDrag a)
            _ ->  \a -> onMouseDown (StartDrag a)

        vertexView : Int -> Svg Action
        vertexView i =
            circle (vertPos i) 0.1 [ fill "darkgrey", eventer i]

        verticesView =
            range |> List.map vertexView

        -- emptyLineView : ( Int, Int ) -> Svg RamseyAction
        -- emptyLineView ( a, b ) =
        --     line (vertPos a) (vertPos b) [ strokeWidth "0.1", onClick ( a, b ), stroke "lightgrey" ]

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

                nx =
                    ax - bx

                ny =
                    ay - by

                nmag =
                    sqrt (nx * nx + ny * ny)

                lx =
                    (ax * t + bx * (1.0 - t)) + (0.1 * -ny / nmag)

                ly =
                    (ay * t + by * (1.0 - t)) + (0.1 * nx / nmag)
            in
                Svg.g []
                    [ line (vertPos a) (vertPos b) [ strokeWidth "0.05", stroke (toColour player) ]
                    , label ( lx, ly ) (toString i) 0.1 [ fill "black" ]
                    ]

        ramseyWinView : List (Svg msg)
        ramseyWinView =
            case ramseyWin state.game of
                Nothing ->
                    []

                Just ( winner, edges ) ->
                    edges
                        |> List.map (\( a, b ) -> line (vertPos a) (vertPos b) [ strokeWidth "0.08", stroke "red" ])

        allLines =
            range |> List.concatMap (\i -> List.range 1 (i - 1) |> List.map (\j -> ( j, i )))

        -- emptyLinesView =
        --     allLines
        --         |> List.filter (\pt -> not <| List.member pt state.game.moves)
        --         |> List.map emptyLineView

        fullLinesView =
            state.game.moves
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

        dragView : List (Svg Action)
        dragView =
            case state.dragState of
            DragMoving i s f ->
                let 
                    fx = toFloat f.x
                    fy = toFloat f.y
                    sy = toFloat s.y
                    sx = toFloat s.x
                    (vx, vy) = vertPos i
                    x = ((fx - sx) / 100.0) + vx
                    y = ((fy - sy) / 100.0) + vy
                in
                    [ line (vx, vy) (x,y) [ strokeWidth "0.05", stroke "green"]
                    ]
            _ -> []
    in
        Svg.g []
            (   
                dragView
                ++ fullLinesView
                ++ ramseyWinView
                ++ verticesView
            )


places : List (Svg msg)
places =
    List.range -2 2
        |> List.concatMap (\i -> List.range -2 2 |> List.map (\j -> ( i, j )))
        |> List.map (\( i, j ) -> label ( toFloat i, toFloat j ) (toString i ++ " , " ++ toString j) 0.1 [])


svgFrame : Svg msg -> Html.Html msg
svgFrame svg =
    Svg.svg [ version "1.1", viewBox (" -1.5 -1.5 3 3") ] [ svg ]


type DragState 
    = DragStart Int
    | DragMoving Int Mouse.Position Mouse.Position
    | DragNone


type alias State =
    { dragState : DragState
    , game : RamseyState}

type Action 
    = StartDrag Int
    | MoveDrag Mouse.Position
    | AbortDrag
    | FinishDrag Int

update : Action -> State -> State
update action state =
    case action of
    StartDrag a -> {state | dragState = DragStart a}
    AbortDrag -> {state | dragState = DragNone}
    MoveDrag pt ->
        case state.dragState of
        DragStart i -> {state | dragState = DragMoving i pt pt }
        DragMoving i startPt _ -> {state | dragState = DragMoving i startPt pt }
        _ -> state
    FinishDrag b ->
        case state.dragState of
        DragNone -> state
        DragStart a -> 
          if a == b then {state | dragState = DragNone} else
          {state | dragState = DragNone, game = ramseyUpdate (a,b) state.game} 
        DragMoving a _ _ -> 
          if a == b then {state | dragState = DragNone} else
          {state | dragState = DragNone, game = ramseyUpdate (a,b) state.game} 

subscriptions : State -> Sub Action
subscriptions state =
    case state.dragState of
    DragStart i -> Mouse.moves (MoveDrag)
    DragMoving _ _ _ -> Mouse.moves (MoveDrag)
    _ -> Sub.none

main =
    Html.programWithFlags
        { view = ramseyView >> svgFrame
        , update = (\a m -> ( update a m, Cmd.none ))
        , init = \i -> ( {game = ramseyInit i, dragState = DragNone}, Cmd.none )
        , subscriptions = subscriptions
        }
