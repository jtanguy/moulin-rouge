module Slides
    exposing
        ( State
        , Msg(..)
        , beginning
        , Config
        , Slideshow
        , slideshow
        , Slide
        , slide
        , view
        , basicProgram
        , Presenter
        , keyboard
        )

{-| This library helps you create slideshows

# Creation
@docs slide, slideshow

# View
@docs view, beginning

# Run
@docs basicProgram, Presenter, keyboard


# Update
@docs Msg

# Definition
@docs Slideshow, Slide, Config, State

-}

import Html exposing (..)
import Html.Attributes exposing (style, type_)
import Styles exposing (..)
import Array exposing (Array, fromList)
import Keyboard.Key exposing (Key, fromCode)
import Keyboard
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
    , update : msg -> State -> State
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
        Slides.slideshow
            { slides =
                [ slide [ h1 [] [ text "Hello World !" ] ] []
                , slide [ h1 [] [ text "The End." ] ] []
                ]
            }

You can then use the `config` and `update` functions in your application
-}
slideshow :
    { slides : List (Slide msg)
    , toMsg : msg -> Maybe Msg
    }
    -> Slideshow msg
slideshow { slides, toMsg } =
    let
        nbSlides =
            List.length slides

        update message (State n) =
            case toMsg message of
                Just Begin ->
                    State 0

                Just End ->
                    State nbSlides

                Just Next ->
                    State (min (n + 1) (nbSlides - 1))

                Just Prev ->
                    State (max (n - 1) 0)

                Nothing ->
                    (State n)
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


{-| Create a simple Program from a slideshow.
-}
basicProgram : List (Slide (Maybe Msg)) -> Program Never State (Maybe Msg)
basicProgram slides =
    let
        { config, update } =
            slideshow { slides = slides, toMsg = identity }

        myupdate msg state =
            update msg state ! []
    in
        program
            { init = beginning ! []
            , subscriptions = \_ -> keyboard.events
            , view = view (config)
            , update = myupdate
            }


{-| Represent a presenting tool, such as a keyboard or a wireless remote.
You can implement your own presenters and use them for your slideshow.
-}
type alias Presenter =
    { events : Sub (Maybe Msg)
    }


{-| A basic keyboard presenter
The Left/Right arrow keys and PageDown/PageUp keys move Forwards and Backwards
respectively, and the Begin/End keys go to the beginning/end of the slideshow.
-}
keyboard : Presenter
keyboard =
    { events =
        let
            decider code =
                case fromCode code of
                    Keyboard.Key.Right ->
                        Just Next

                    Keyboard.Key.Left ->
                        Just Prev

                    Keyboard.Key.PageDown ->
                        Just Next

                    Keyboard.Key.PageUp ->
                        Just Prev

                    Keyboard.Key.Home ->
                        Just Begin

                    Keyboard.Key.End ->
                        Just End

                    _ ->
                        Nothing
        in
            Keyboard.downs decider
    }
