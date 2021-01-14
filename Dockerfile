FROM rust:1-slim-buster as cargo-install
WORKDIR /code
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo install --path .

FROM debian:buster-slim
COPY --from=cargo-install /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/docker-compose-updater
CMD ["docker-compose-updater"]
