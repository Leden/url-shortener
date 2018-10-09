module Config exposing (Config, config)


type alias Config =
    { api : String }


config : Config
config =
    { api = "//localhost:8080" }
