module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



--


type alias Model =
    Int


init : Model
init =
    0


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Counter" ]
        , button [ onClick Increment ] [ text "+" ]
        , p [] [ text ("Count: " ++ String.fromInt model) ]
        , button [ onClick Decrement ] [ text "-" ]
        ]
