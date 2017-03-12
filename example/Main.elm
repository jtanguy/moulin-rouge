module Main exposing (..)

import Html exposing (..)
import Keyboard.Key exposing (Key(Left, Right, Home, End), fromCode)
import Keyboard
import Slides exposing (slide)


main =
    Slides.basicProgram
        [ slide [] [ h1 [] [ text (toString 0) ] ]
        , slide [] [ h1 [] [ text (toString 1) ] ]
        , slide [] [ h1 [] [ text (toString 2) ] ]
        , slide [] [ h1 [] [ text (toString 3) ] ]
        , slide [] [ h1 [] [ text (toString 4) ] ]
        ]
