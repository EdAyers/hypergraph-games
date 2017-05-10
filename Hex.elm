module Hex exposing (..)

import Svg exposing (..)
import Html exposing (div, button)
import Html.Events
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Set exposing (Set)

type Player
    = P1
    | P2


type alias Pt =
    ( Int, Int )


type alias HexMove =
    ( Pt, Player )


type alias HexState =
    { size : Int
    , count : Int
    , moves : List HexMove 
    }


type HexAction
    = Reset
    | Move Pt
    | IncrementSize
    | DecrementSize


toCol : Player -> String
toCol x =
    case x of
        P1 ->
            "blue"

        P2 ->
            "orange"


toFF : Pt -> ( Float, Float )
toFF ( a, b ) =
    ( toFloat a, toFloat b )


skew : ( Float, Float ) -> ( Float, Float )
skew ( fx, fy ) =
    ( (fx + fy * cos (pi / 3.0)), fy * sin (pi / 3.0) )


toPos : ( Float, Float ) -> ( String, String )
toPos =
    skew >> ffToStr


ffToStr : ( Float, Float ) -> ( String, String )
ffToStr ( x, y ) =
    ( toString x, toString y )


ngon : Int -> Float -> List ( Float, Float )
ngon n r =
    List.range 1 n
        |> List.map
            (\i ->
                let
                    a =
                        2 * pi * (toFloat i) / (toFloat n)
                in
                    ( r * sin (a), r * cos (a) )
            )


hexagon : Pt -> String -> Float -> Svg HexAction
hexagon pt colour r =
    let
        center =
            pt |> toFF |> skew

        pl ( ax, ay ) ( bx, by ) =
            ( ax + bx, ay + by )

        hex =
            ngon 6 r
                |> List.map (pl center >> ffToStr)
                |> List.map (\( x, y ) -> x ++ ", " ++ y ++ " ")
                |> List.foldl (++) ""
    in
        polygon [ points hex, fill colour, onClick (Move pt) ] []


vertex : Pt -> Svg HexAction
vertex pos =
    let
        ( sx, sy ) =
            pos |> toFF |> toPos
    in
        g []
            [ hexagon pos "LightGrey" 0.5
            ]

pick : (a -> Maybe b) -> List a -> Maybe b
pick pred l =
    case l of
    [] -> Nothing
    h :: t ->
      case pred h of 
      Nothing -> pick pred t
      Just b -> Just b

whosTurn : Int -> Player
whosTurn x = if (x % 2) == 0 then P1 else P2



findWin : HexState -> Maybe (List Pt)
findWin state  =
    let 
        player = state |> .count |> ((+) 1) |> whosTurn
        finish = (state.size + 1, state.size + 1)

        a = totalMoves state |> List.filterMap (\(pt,p) ->if p == player then Just pt else Nothing ) |> Set.fromList |> Set.insert finish
        adj : Pt -> Set Pt
        adj (x,y) = [(x, y + 1), (x, y - 1), (x + 1, y) , (x - 1, y), (x + 1, y - 1), (x - 1 , y + 1)] |> Set.fromList
        folder : List Pt -> (Set Pt, List(List Pt))-> (Set Pt, List(List Pt))
        folder path (a, acc) =
            case path of
            [] -> (a, acc)
            h :: t -> 
              let b = adj h 
                  a2 : Set Pt
                  a2 = Set.diff a b
                  acc2 : List(List Pt)
                  acc2 = Set.intersect a b |> Set.toList |> List.map (\h2 -> h2 :: h :: t) |> List.append acc
              in (a2 , acc2)

        rec : (Set Pt) -> (List (List Pt)) -> (Maybe (List Pt))
        rec a paths = 
            case List.foldl folder (a, []) paths of
            (a2, []) -> Nothing
            (a2, paths) ->
                case pick (\path -> List.head path |> Maybe.andThen (\pt -> if pt == finish then Just path else Nothing)) paths of
                Nothing -> rec a2 paths
                Just path -> Just path
            
    in
        rec a [[(-1,-1)]]

renderWin : HexState -> List (Svg HexAction)
renderWin state =
    let 
        finish = (state.size + 1, state.size + 1)
        player = state.count  + 1 |> whosTurn
    in
        case findWin state of
        Just path ->
            path 
            |> List.scanl (\a (b,c) -> (a, b)) (finish, finish)
            |> List.map (\(a,b) -> renderJoiner a b "red")
        Nothing -> []


renderMove : Int -> HexMove -> Svg HexAction
renderMove n ( pt, player ) =
    let
        ( sx, sy ) =
            pt |> toFF |> toPos
    in
        g [ transform ("translate(" ++ sx ++ " , " ++ sy ++ ")") ]
            [ circle [ cx "0", cy "0", fill (toCol player), r "0.3" ] []
            , text_ [ fontSize "0.3", fill "white", textAnchor "middle", dominantBaseline "middle" ] [ text (toString n) ]
            ]


renderJoiner : Pt -> Pt -> String -> Svg HexAction
renderJoiner p1 p2 player =
    let
        ( p1x, p1y ) =
            p1 |> toFF |> skew |> ffToStr

        ( p2x, p2y ) =
            p2 |> toFF |> skew |> ffToStr
    in
        line [ stroke player, strokeLinecap "round", strokeWidth "0.1", x1 p1x, x2 p2x, y1 p1y, y2 p2y ] []

-- Get the moves including the 'gutter' positions.
totalMoves : HexState -> List HexMove
totalMoves { moves, size } =
    let
        l =
            List.range 0 size
    in
        [ l |> List.map (\i -> ( ( i, -1 ), P2 ))
        , l |> List.map (\i -> ( ( i, size + 1 ), P2 ))
        , l |> List.map (\i -> ( ( -1, i ), P1 ))
        , l |> List.map (\i -> ( ( size + 1, i ), P1 ))
        , moves
        ]
            |> List.concat


renderJoiners : HexState -> List (Svg HexAction)
renderJoiners state =
    let
        a =
            totalMoves state
    in
        a
            |> List.concatMap
                (\( ( x, y ), player ) ->
                    [ ( x + 1, y )
                    , ( x, y + 1 )
                    , ( x - 1, y + 1 )
                    ]
                        |> List.filter (\p1 -> List.member ( p1, player ) a)
                        |> List.map (\p2 -> renderJoiner ( x, y ) p2 (toCol player))
                )


vertexPoints : Int -> List Pt
vertexPoints size =
    List.range 0 size
        |> List.map (\x -> List.range 0 size |> List.map (\y -> ( x, y )))
        |> List.concat


view : Model -> Html.Html Action
view (Model ({ size, count, moves } as state) stack) =
    let
        fs =
            toFloat size

        ( h, w ) =
            ( size + 4, size + 4 ) |> toFF |> toPos
    in
        div []
            [ 
                div [class "toolbar"] [
                 button [ Html.Events.onClick (Do Reset) ] [ text "new game" ],
                 button [Html.Events.onClick (Undo)] [text "undo"],
                 button [Html.Events.onClick (Do DecrementSize)] [text "<"],
                 button [Html.Events.onClick (Do IncrementSize)] [text ">"]
                ]
            , (svg [ version "1.1", viewBox (" -2 -2 " ++ h ++ " " ++ w ++ " ") ]
                ((List.map vertex (vertexPoints size))
                    ++ (renderJoiners state)
                    ++ renderWin state
                    ++ (List.indexedMap (\i -> renderMove (count - i)) moves)
                 -- ++ [ gutter ( -1, 0 ) ( -1, fs ) P1
                 --    , gutter ( 0, -1 ) ( fs, -1 ) P2
                 --    , gutter ( fs + 1, 0 ) ( fs + 1, fs ) P1
                 --    , gutter ( 0, fs + 1 ) ( fs, fs + 1 ) P2
                 --    ]
                )) |> Svg.map (Do)
            ]

type Model = Model HexState (Maybe Model)
type Action
    = Undo
    | Do HexAction

update : Action -> Model -> Model
update a (Model hex stack) =
    case a of
    Undo ->
        case stack of
        Just x -> x
        Nothing -> Model hex stack
    Do a -> Model (hexUpdate a hex) (Just (Model hex stack))

initialise  : Int -> HexState
initialise n =
    {size = n, count = 0, moves = []}

hexUpdate : HexAction -> HexState -> HexState
hexUpdate msg state =
    case msg of
        IncrementSize -> initialise (state.size + 1)
        DecrementSize -> if (state.size <= 1) then state else initialise (state.size - 1)
        Reset -> initialise state.size

        Move pt ->
            if List.any (\( pt2, _ ) -> pt == pt2) state.moves then
                state
            else
                { state
                    | count = state.count + 1
                    , moves =
                        ( pt
                        , if (state.count % 2) == 0 then
                            P1
                          else
                            P2
                        )
                            :: state.moves
                }


main : Program Never Model Action
main =
    Html.beginnerProgram { model = Model (initialise 5) Nothing, view = view, update = update }


elmLogo : Html.Html HexAction
elmLogo =
    svg
        [ version "1.1"
        , x "0"
        , y "0"
        , viewBox "0 0 323.141 322.95"
        ]
        [ polygon [ fill "#F0AD00", points "161.649,152.782 231.514,82.916 91.783,82.916" ] []
        , polygon [ fill "#7FD13B", points "8.867,0 79.241,70.375 232.213,70.375 161.838,0" ] []
        , rect
            [ fill "#7FD13B"
            , x "192.99"
            , y "107.392"
            , width "107.676"
            , height "108.167"
            , transform "matrix(0.7071 0.7071 -0.7071 0.7071 186.4727 -127.2386)"
            ]
            []
        , polygon [ fill "#60B5CC", points "323.298,143.724 323.298,0 179.573,0" ] []
        , polygon [ fill "#5A6378", points "152.781,161.649 0,8.868 0,314.432" ] []
        , polygon [ fill "#F0AD00", points "255.522,246.655 323.298,314.432 323.298,178.879" ] []
        , polygon [ fill "#60B5CC", points "161.649,170.517 8.869,323.298 314.43,323.298" ] []
        ]
