module Main exposing (..)

import Html exposing (..)
import Keyboard.Key exposing (Key(Left, Right, Home, End), fromCode)
import Keyboard
import Slides exposing (slide)


type alias Model =
    { state : Slides.State
    }


type Msg
    = JumpTo Slides.Jump
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
                    JumpTo Slides.Next

                Left ->
                    JumpTo Slides.Prev

                Home ->
                    JumpTo Slides.Begin

                End ->
                    JumpTo Slides.End

                _ ->
                    NoOp
    in
        Keyboard.downs decider


main =
    program
        { init = initial ! []
        , subscriptions = \_ -> keyEvents
        , view = view
        , update = update
        }


update msg model =
    case msg of
        JumpTo j ->
            { model | state = jumpTo j model.state } ! []

        NoOp ->
            model ! []


{ config, jumpTo } =
    Slides.config
        { slides =
            [ slide [ h1 [] [ text (toString 0) ] ] []
            , slide [ h1 [] [ text (toString 1) ] ] []
            , slide [ h1 [] [ text (toString 2) ] ] []
            , slide [ h1 [] [ text (toString 3) ] ] []
            , slide [ h1 [] [ text (toString 4) ] ] []
            ]
        }


view : Model -> Html Msg
view model =
    Slides.view config model.state
