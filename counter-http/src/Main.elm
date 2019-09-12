module Main exposing (Msg(..), main, update, view)

import Browser
import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (disabled, src)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, int, map2, string)
import Url.Builder as UrlBuilder


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }



-- Model + Decoder


type alias Uuid =
    String


type alias Counter =
    { id : Uuid
    , value : Int
    }


counterDecoder =
    map2 Counter (field "id" string) (field "value" int)


type Operation
    = Increment
    | Decrement


type alias Model =
    { counter : Maybe Counter
    , activeRequest : Maybe Operation
    }


type Msg
    = IncrementCounter
    | DecrementCounter
    | GotCounter (Result Http.Error Counter)



-- App logic


apiUrl =
    "https://caas-demo.herokuapp.com/counter"


init flags =
    ( { counter = Nothing
      , activeRequest = Nothing
      }
    , createCounter
    )


createCounter : Cmd Msg
createCounter =
    Http.request
        { body = Http.emptyBody
        , method = "POST"
        , url = UrlBuilder.crossOrigin apiUrl [] []
        , expect = Http.expectJson GotCounter counterDecoder
        , headers = [ Http.header "Content-Type" "application/json" ]
        , timeout = Nothing
        , tracker = Nothing
        }


changeCounterValue : Uuid -> Operation -> Cmd Msg
changeCounterValue uuid op =
    let
        opString =
            case op of
                Increment ->
                    "increment"

                Decrement ->
                    "decrement"
    in
    Http.request
        { body = Http.emptyBody
        , method = "PUT"
        , url = UrlBuilder.crossOrigin apiUrl [ uuid, opString ] []
        , expect = Http.expectJson GotCounter counterDecoder
        , headers = [ Http.header "Content-Type" "application/json" ]
        , timeout = Nothing
        , tracker = Nothing
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncrementCounter ->
            case model.counter of
                Just c ->
                    ( { model | activeRequest = Just Increment }, changeCounterValue c.id Increment )

                Nothing ->
                    ( model, Cmd.none )

        DecrementCounter ->
            case model.counter of
                Just c ->
                    ( { model | activeRequest = Just Decrement }, changeCounterValue c.id Decrement )

                Nothing ->
                    ( model, Cmd.none )

        GotCounter result ->
            case result of
                Ok counter ->
                    ( { model | counter = Just counter, activeRequest = Nothing }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    let
        areButtonsDisabled =
            model.activeRequest /= Nothing

        isCounterValueZero =
            case model.counter of
                Just c ->
                    c.value == 0

                Nothing ->
                    False
    in
    div []
        [ h1 [] [ text "Counter" ]
        , button [ onClick IncrementCounter, disabled areButtonsDisabled ] [ text "+" ]
        , case model.counter of
            Just c ->
                p [] [ text ("Count: " ++ String.fromInt c.value) ]

            Nothing ->
                text "No counter yet"
        , button [ onClick DecrementCounter, disabled (areButtonsDisabled || isCounterValueZero) ] [ text "-" ]
        ]
