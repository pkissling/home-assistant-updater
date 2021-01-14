FROM --platform=$BUILDPLATFORM rust:1-slim-buster as builder
WORKDIR /code
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
RUN rustup update nightly
RUN rustup override set nightly
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install --target x86_64-unknown-linux-musl --path .

FROM debian:buster-slim
#RUN apk add bash docker
COPY --from=builder /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/docker-compose-updater
CMD ["docker-compose-updater"]