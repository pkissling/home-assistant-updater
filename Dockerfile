FROM rust:latest as builder
WORKDIR /usr/src/docker-compose-updater
COPY src/ src/
COPY Cargo.toml .
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo install --path .

FROM debian:buster-slim
COPY --from=builder /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/
CMD ["docker-compose-updater"]