module UrlShortener.ClientId exposing (ClientId, generator)

import Json.Decode
import Json.Encode
import Random


-- TYPES


type ClientId
    = ClientId String



-- GENERATOR


generator : Random.Generator ClientId
generator =
    Random.map
        (toString >> ClientId)
        (Random.int 1000 9999)
