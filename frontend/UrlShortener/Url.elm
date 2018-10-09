module UrlShortener.Url exposing (Url, decoder)

-- LIBS

import Json.Decode exposing (field, string)
import Random


-- PROJECT

import UrlShortener.Code exposing (Code(Code))


-- TYPES


type alias Url =
    { code : Code
    , long : String
    }



-- INIT


decoder : Json.Decode.Decoder Url
decoder =
    Json.Decode.map2
        (\code long -> Url (Code code) long)
        (field "code" string)
        (field "long" string)
