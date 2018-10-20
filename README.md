# URL SHORTENER

A simple url shortener

## Development

To bootstrap the environment, run

    ./scripts/bootstrap.sh


## Architecture

### Frontend

Elm


### Backend

Elixir


#### Store

A process which stores the shortened urls with their full versions.

API:
* Save shortened url (short, full)
* List urls ()
* Delete shortened url (short)
* Get full url (short)


#### ID Generator

A module which generates a unique ID for short url each time it's asked.

API:
* next ID: (previous ID)


#### HTTP Worker

A Plug Process which handles the CRUD HTTP requests and maps them to controller functions.


#### Controller

A module with http api implementations, delegating to ID Generator and Store.


#### HTTP API

* GET /urls : list all the urls in the store
* POST /urls : shorten a new url
* GET /urls/{url-id} : get shortened url data
* DELETE /urls/{url-id} : remove shortened url
* GET /{short-url} : redirect to full version

### Persistence

None yet
