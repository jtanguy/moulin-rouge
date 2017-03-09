module Styles exposing (class, classList, css, SlideClasses(..))

import Css exposing (..)
import Css.Elements exposing (body)
import Css.Namespace exposing (namespace)
import Html.CssHelpers exposing (withNamespace)


mrNamespace =
    "moulinRouge"


{ id, class, classList } =
    withNamespace mrNamespace


type SlideClasses
    = Slide
    | Centered
    | Black


css =
    (stylesheet << namespace mrNamespace)
        [ body
            [ margin zero
            ]
        , Css.class Slide
            [ displayFlex
            , flexDirection column
            , alignItems center
            , justifyContent flexStart
            , withClass Centered
                [ justifyContent center
                ]
            , width (vw 100)
            , height (vh 100)
            ]
        , mediaQuery "screen and ( orientation: portrait )"
            [ Css.class Slide
                [ height (vmin 56) ]
            ]
        , Css.class Black
            [ backgroundColor (hex "111")
            , color (hex "eee")
            ]
        ]
