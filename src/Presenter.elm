module Presenter exposing (..)


type alias Presenter =
    { next : KeyCode
    , prev : KeyCode
    , start : Maybe KeyCode
    , blank : Maybe KeyCode
    }


logitechR800 : Presenter
logitechR800 =
    { next = 34
    , prev = 33
    , start = Nothing
    , blank = Nothing
    }
