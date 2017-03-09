module Slides
    exposing
        ( State
        , Msg(..)
        , beginning
        , Config
        , Slideshow
        , config
        , Slide
        , slide
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (style, type_)
import Styles exposing (..)
import Array exposing (Array, fromList)
import Css


type State
    = State Int


type Msg
    = Next
    | Prev
    | Begin
    | End


type alias Slideshow msg =
    { config : Config msg
    , jumpTo : Jump -> State -> State
    }


beginning =
    State 0


type Config msg
    = Config
        { slides : Array (Slide msg)
        }


config :
    { slides : List (Slide msg)
    }
    -> Slideshow msg
config { slides } =
    let
        nbSlides =
            List.length slides

        update dir (State n) =
            case dir of
                Begin ->
                    State 0

                End ->
                    State nbSlides

                Next ->
                    State (min (n + 1) nbSlides)

                Prev ->
                    State (max (n - 1) 0)
    in
        { config =
            Config
                { slides = fromList slides
                }
        , update = update
        }


type Slide msg
    = MkSlide (List ( String, String )) (List (Html msg))


slide : List ( String, String ) -> List (Html msg) -> Slide msg
slide =
    MkSlide


endSlide : Slide msg
endSlide =
    slide
        [ ( "background-color", "#111" )
        , ( "color", "#eee" )
        ]
        [ text "Fin." ]


cssStyles =
    let
        { css, warnings } =
            Css.compile [ Styles.css ]
    in
        Html.node "style" [ type_ "text/css" ] [ text css ]


view : Config msg -> State -> Html msg
view (Config { slides }) (State num) =
    case Array.get num slides of
        Just s ->
            div [] [ cssStyles, viewSlide s ]

        Nothing ->
            div [] [ cssStyles, viewSlide endSlide ]


viewSlide : Slide msg -> Html msg
viewSlide (MkSlide styles elems) =
    div
        ([ class
            (if List.length elems > 1 then
                [ Slide ]
             else
                [ Slide, Centered ]
            )
         , style styles
         ]
        )
        elems
