port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing (class, id, src)
import Html.Events exposing (onClick)



---- I/0 ----
-- Inboud --


port pictureTaken : (String -> msg) -> Sub msg



-- Outbound --


port takePhoto : () -> Cmd msg



---- MODEL ----


type alias Model =
    { currentPicture : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { currentPicture = Nothing
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = TakePhoto
    | PictureTaken String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TakePhoto ->
            ( model, takePhoto () )

        PictureTaken content ->
            ( { model | currentPicture = Just content }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick TakePhoto ] [ text "Take photo" ]
        , photoView model.currentPicture
        ]


photoView currentPicture =
    let
        baseAttributes =
            [ id "photo" ]

        imgAttributes =
            case currentPicture of
                Just content ->
                    baseAttributes ++ [ src content ]

                Nothing ->
                    baseAttributes
    in
    div [ class "output" ]
        [ img imgAttributes []
        ]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    pictureTaken PictureTaken


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
