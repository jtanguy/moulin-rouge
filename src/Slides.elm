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

{-| This library helps you create slideshows

# Creation
@docs slide, config

# View
@docs view, beginning

# Update
@docs Msg

# Definition
@docs Slideshow, Slide, Config, State

-}

import Html exposing (..)
import Html.Attributes exposing (style, type_)
import Styles exposing (..)
import Array exposing (Array, fromList)
import Css


{-| Track the current state of the slideshow
-}
type State
    = State Int


{-| Represent the set of actions one can perform in the slideshow
-}
type Msg
    = Next
    | Prev
    | Begin
    | End


{-| Helpers for working with a slideshow
-}
type alias Slideshow msg =
    { config : Config msg
    , update : Msg -> State -> State
    }


{-| Create a slideshow state. It's the first slide
-}
beginning : State
beginning =
    State 0


{-| Configuration for your slideshow, with all the slides.

**Note:** Your `Config` should *never* be held in your model.
It should only appear in `view` code.
-}
type Config msg
    = Config
        { slides : Array (Slide msg)
        }


{-| Create a slideshow configuration and returns a helper function to update the
slideshow state.

    { config, update } =
        Slides.config
            { slides =
                [ slide [ h1 [] [ text "Hello World !" ] ] []
                , slide [ h1 [] [ text "The End." ] ] []
                ]
            }

You can then use the `config` and `update` functions in your application
-}
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


{-| Represents a slide contents
-}
type Slide msg
    = MkSlide (List ( String, String )) (List (Html msg))


{-| Create a slide with its contents and style.

    mySlide : Slide msg
    mySlide =
        slide
            [ ( "background-color", "#111" )
            , ( "color", "#eee" )
            ]
            [ text "Hello world !" ]

For more complex css, you might want to use a library like
[elm-css](http://package.elm-lang.org/packages/rtfeldman/elm-css/latest).
-}
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


{-| Take a slideshow and turn it into html. The `Config` argument is the
slideshow configuration, given by `Slides.config`.

    view : { model | state: State} -> Html msg
    view model =
        Slides.view config model.state

**Note:** Your `Config` should *not* be  in your model, and the `State` should
only be in the model.
-}
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
