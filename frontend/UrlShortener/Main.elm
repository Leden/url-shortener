module UrlShortener.Main exposing (main)

-- LIBS

import Html exposing (Html, div, text)
import Http
import Json.Decode
import Json.Encode
import Navigation
import Random
import Ui.Button
import Ui.Container
import Ui.Header
import Ui.Input
import Ui.Layout
import Ui.Link
import Ui.NotificationCenter


-- PROJECT

import Config exposing (Config)
import UrlShortener.ClientId as ClientId exposing (ClientId)
import UrlShortener.Code as Code
import UrlShortener.Url as Url exposing (Url)


-- TYPES


type UrlItem
    = Saved Url
    | Saving ClientId String


type alias Model =
    { input : Ui.Input.Model
    , button : Ui.Button.Model
    , notificationCenter : Ui.NotificationCenter.Model Msg
    , urls : List UrlItem
    , currentLocation : Navigation.Location
    , config : Config
    }



-- MESSAGES


type Msg
    = Input Ui.Input.Msg
    | NotificationCenter Ui.NotificationCenter.Msg
    | ShortenBtnClick
    | DisplayNewUrl String ClientId
    | UrlSaveServerResponse ClientId (Result Http.Error Url)
    | UrlListServerResponse (Result Http.Error (List Url))
    | UrlChange Navigation.Location



-- INIT


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        input =
            Ui.Input.init ()
                |> Ui.Input.placeholder "URL to shorten..."
                |> Ui.Input.showClearIcon True

        button0 =
            Ui.Button.model "Shorten" "primary" "medium"

        button =
            { button0 | disabled = True }

        urls =
            []

        notificationCenter =
            Ui.NotificationCenter.init ()

        config =
            Config.config
    in
        ( { input = input
          , button = button
          , urls = urls
          , notificationCenter = notificationCenter
          , currentLocation = location
          , config = config
          }
        , loadUrls config.api
        )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model =
    case msg_ of
        Input msg ->
            let
                ( input, cmd ) =
                    Ui.Input.update msg model.input

                button =
                    model.button

                buttonDisabled =
                    case input.value of
                        "" ->
                            True

                        _ ->
                            False
            in
                ( { model
                    | input = input
                    , button = { button | disabled = buttonDisabled }
                  }
                , Cmd.map Input cmd
                )

        NotificationCenter msg ->
            let
                ( updatedNotificationCenter, cmd ) =
                    Ui.NotificationCenter.update msg model.notificationCenter
            in
                ( { model
                    | notificationCenter = updatedNotificationCenter
                  }
                , Cmd.map NotificationCenter cmd
                )

        ShortenBtnClick ->
            let
                value =
                    model.input.value

                ( input, inputCmd ) =
                    Ui.Input.setValue "" model.input
            in
                ( { model
                    | input = input
                  }
                , Cmd.batch
                    [ Cmd.map Input inputCmd
                    , Random.generate (DisplayNewUrl value) ClientId.generator
                    ]
                )

        DisplayNewUrl long clientId ->
            let
                urls =
                    Saving clientId long :: model.urls
            in
                ( { model | urls = urls }
                , saveUrl model.config.api clientId long
                )

        UrlSaveServerResponse clientId result ->
            case result of
                Ok url ->
                    let
                        urls =
                            List.map (urlItemMap clientId url) model.urls
                    in
                        ( { model | urls = urls }, Cmd.none )

                Err error ->
                    notifyError "HTTP Error"
                        { model
                            | urls = List.filter saved model.urls
                        }

        UrlListServerResponse (Ok urls) ->
            ( { model | urls = (List.map Saved urls) }, Cmd.none )

        UrlListServerResponse (Err error) ->
            notifyError "HTTP Error" model

        UrlChange location ->
            ( { model | currentLocation = location }
            , Cmd.none
            )


saved : UrlItem -> Bool
saved urlItem =
    case urlItem of
        Saved _ ->
            True

        _ ->
            False


notifyError : String -> Model -> ( Model, Cmd Msg )
notifyError error model =
    let
        ( updatedNotificationCenter, ncCmd ) =
            Ui.NotificationCenter.notify (text error) model.notificationCenter
    in
        ( { model
            | notificationCenter = updatedNotificationCenter
          }
        , Cmd.map NotificationCenter ncCmd
        )


urlItemMap : ClientId -> Url -> UrlItem -> UrlItem
urlItemMap clientId url urlItem =
    case urlItem of
        Saving clientId long ->
            Saved url

        Saved _ ->
            urlItem



-- VIEW


view : Model -> Html.Html Msg
view model =
    Ui.Layout.website
        [ Ui.Header.view
            [ Ui.Header.title
                { action = Nothing
                , target = "_self"
                , link = Nothing
                , text = "Yet Another Url Shortener"
                }
            , Ui.NotificationCenter.view NotificationCenter model.notificationCenter
            ]
        ]
        [ Ui.Container.column []
            [ Ui.Container.rowCenter []
                [ div [] [ Html.map Input (Ui.Input.view model.input) ]
                , div [] [ Ui.Button.view ShortenBtnClick model.button ]
                ]
            , urlsView model
            ]
        ]
        -- TODO: footer?
        [ text "footer"
        ]


urlsView : Model -> Html.Html Msg
urlsView model =
    Ui.Container.column [] <|
        List.map (urlView model.config.api) model.urls


urlView : String -> UrlItem -> Html.Html Msg
urlView host urlItem =
    case urlItem of
        Saved url ->
            let
                longUrl =
                    url.long

                longContents =
                    [ text longUrl ]

                longLink =
                    Ui.Link.Model longContents (Just "_blank") (Just longUrl) Nothing

                shortUrl =
                    host ++ "/" ++ Code.toString url.code

                shortContents =
                    [ text shortUrl ]

                shortLink =
                    Ui.Link.Model shortContents (Just "_blank") (Just shortUrl) Nothing
            in
                Ui.Container.rowCenter []
                    [ div []
                        [ Ui.Link.view shortLink
                        , text " -> "
                        , Ui.Link.view longLink
                        ]
                    ]

        Saving clientId long ->
            let
                longUrl =
                    long

                longContents =
                    [ text longUrl ]

                longLink =
                    Ui.Link.Model longContents (Just "_blank") (Just longUrl) Nothing
            in
                Ui.Container.rowCenter []
                    [ div []
                        [ Ui.Link.view longLink
                        ]
                    ]



-- HTTP


saveUrl : String -> ClientId -> String -> Cmd Msg
saveUrl host clientId long =
    let
        body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "long", Json.Encode.string long )
                    ]
                )

        endpoint =
            "//" ++ host ++ "/urls"

        request =
            Http.post endpoint body Url.decoder

        msg =
            UrlSaveServerResponse clientId
    in
        Http.send msg request


loadUrls : String -> Cmd Msg
loadUrls host =
    let
        decoder =
            Json.Decode.list Url.decoder

        request =
            Http.get (host ++ "/urls") decoder
    in
        Http.send UrlListServerResponse request



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
