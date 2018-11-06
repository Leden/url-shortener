# Yet Another Url shortener :: Architecture

## Frontend

Just Elm Architecture, nothing special

## Backend

Inspired by [hexagonal architecture](https://fideloper.com/hexagonal-architecture).

```
/
  url_shortener/
    data/
      link.ex
    services/
      cache.ex
      code_generator.ex
      link_crud.ex
      persistence.ex
    adapters/
      database/
        repo.ex
      http/
        router.ex
```

```

[A] Http -> [S] LinkCrud -> {[S] CodeGenerator,
                             [S] Persistence -> [A] Database,
                             [S] Cache}


```


### Core

Data (data) + Services (logic).


#### Data

Domain model data structures:

  * Link


#### Services

Domain logic:

  * Link CRUD operations
  * Code generation
  * Caching
  * Persistence


### Adapters

The interfaces with outer world:

  * Http
  * Database


#### Http

Plug Endpoint <=-> Http clients


#### Database

Ecto Repo <-=> PostgreSQL DB.
