FROM elixir:latest

ARG QL_MODE
ENV QL_MODE=$QL_MODE

COPY assets/ops/setup_security.sh /
RUN /setup_security.sh

RUN apt-get update
RUN apt-get install --yes build-essential inotify-tools postgresql-client fish

# Install Phoenix packages
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

# Install node
RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install nodejs

WORKDIR /app
EXPOSE 8800

COPY assets/ops/config.fish /root/.config/fish/config.fish

ENTRYPOINT fish
