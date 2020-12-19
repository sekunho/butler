FROM boreddevco/alpine-elixir-phoenix:1.11.2 AS phx-builder

# TODO: Use Ubuntu image instead

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
# Install `matrex` dependencies.
RUN \
    apk --no-cache --update add \
    erlang-dev \
    build-base \
    gcc \
    git \
    lapack \
    lapack-dev \
    musl \
    libgfortran \
    openblas-dev \
    openblas && \
    rm -rf /var/cache/apk/*

RUN ln -s /usr/include/locale.h /usr/include/xlocale.h

# Set exposed ports
ENV MIX_ENV=prod MATREX_BLAS=openblas

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do clean, deps.get, deps.compile

# Same with npm deps
ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest && \
    mix release --overwrite

FROM boreddevco/alpine-elixir:1.11.2

EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
# Install `matrex` dependencies.
RUN \
    apk --no-cache --update add \
    erlang-dev \
    build-base \
    gcc \
    lapack \
    lapack-dev \
    musl \
    libgfortran \
    openblas-dev \
    openblas && \
    rm -rf /var/cache/apk/*

COPY --from=phx-builder /opt/app/_build /opt/app/_build
COPY --from=phx-builder /opt/app/priv /opt/app/priv
COPY --from=phx-builder /opt/app/config /opt/app/config
COPY --from=phx-builder /opt/app/lib /opt/app/lib
COPY --from=phx-builder /opt/app/deps /opt/app/deps
COPY --from=phx-builder /opt/app/mix.* /opt/app/

CMD ["_build/prod/rel/butler/bin/butler", "start"]
