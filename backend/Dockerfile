FROM elixir:1.7

RUN apt-get update

RUN mix local.hex --force && \
	apt-get install -y byobu inotify-tools

WORKDIR /app/url_shortener

CMD mix local.rebar --force && \
	mix deps.get && \
	iex -S mix
