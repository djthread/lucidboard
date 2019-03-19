FROM elixir:latest

ARG QL_MODE
ENV QL_MODE=$QL_MODE

COPY ./assets/ops/setup_security.sh /

# Install tools
RUN apt-get update && apt-get install --yes build-essential inotify-tools postgresql-client fish vim

# Install Phoenix packages
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

WORKDIR /app
EXPOSE 8800

COPY ./assets/ops/config.fish /root/.config/fish/config.fish

ENTRYPOINT fish
