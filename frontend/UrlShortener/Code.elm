module UrlShortener.Code exposing (Code(..), toString)

-- TYPES


type Code
    = Code String



-- READ


toString : Code -> String
toString code =
    case code of
        Code string ->
            string
