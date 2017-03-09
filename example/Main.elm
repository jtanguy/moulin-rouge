module Main exposing (..)

import Html exposing (..)
import Keyboard.Key exposing (Key(Left, Right, Home, End), fromCode)
import Keyboard
import Slides exposing (slide)


type alias Model =
    { state : Slides.State
    }


type Msg
    = SlideMsg Slides.Msg
    | NoOp


initial : Model
initial =
    { state = Slides.beginning
    }


keyEvents : Sub Msg
keyEvents =
    let
        decider code =
            case fromCode code of
                Right ->
                    SlideMsg Slides.Next

                Left ->
                    SlideMsg Slides.Prev

                Home ->
                    SlideMsg Slides.Begin

                End ->
                    SlideMsg Slides.End

                _ ->
                    NoOp
    in
        Keyboard.downs decider


main =
    program
        { init = initial ! []
        , subscriptions = \_ -> keyEvents
        , view = view
        , update = myupdate
        }


myupdate msg model =
    case msg of
        SlideMsg j ->
            { model | state = update j model.state } ! []

        NoOp ->
            model ! []


{ config, update } =
    Slides.config
        { slides =
            [ slide [] [ h1 [] [ text (toString 0) ] ]
            , slide [] [ h1 [] [ text (toString 1) ] ]
            , slide [] [ h1 [] [ text (toString 2) ] ]
            , slide [] [ h1 [] [ text (toString 3) ] ]
            , slide [] [ h1 [] [ text (toString 4) ] ]
            ]
        }


view : Model -> Html Msg
view model =
    Slides.view config model.state
