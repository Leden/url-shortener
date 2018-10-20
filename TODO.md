# Yet Another Url Shortener

## MVP / V1

### Development goodness

* [x] `tech` host the code on Github
* [x] `tech` `frontend` configurable backend host url for frontend
* [x] `tech` `frontend` one command dev env setup: dockerize frontend
* [x] `tech` `backend` tests for api errors
* [ ] `tech` `backend` code inspections (Credo?)


### Feature-completeness

* [ ] `feature` Persistence
* [x] `feature` Better string code generation
	- https://github.com/alco/hashids-elixir
	- https://github.com/dvv/base64url
	- https://github.com/jrdnull/base58
	- https://github.com/igas/base62


### Launch

* [ ] `tech` Deploy for real
	- [ ] Runtime configuration (:secret_key, DB settings, etc)


## V2

### New frontend

* [ ] `feature` Redesign frontend
* [ ] `tech` `frontend` upgrade to Elm 0.19
* [ ] `tech` `frontend` rewrite frontend on create-elm-app (or alternative) foundation


### Tech awesomeness

* [ ] `tech` `frontend` frontend: generate api layer from swagger docs
* [ ] `tech` `backend` backend: swagger api docs (+ maru?)
* [ ] `tech` `frontend` `backend` document the code


## V3

### Link management

* [ ] `feature` Click tracking
* [ ] `feature` Customizable routing


## Backlog

* [ ] `tech` `backend` `frontend` Event-based API (websocket)
* [ ] `tech` `backend` Rewrite to Phoenix?
* [ ] `tech` make a cookiecutter(-like) template based on this project
