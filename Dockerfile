FROM rust:latest as builder
WORKDIR /usr/src/docker-compose-updater
COPY src/ src/
COPY Cargo.toml .
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo install --path .

FROM debian:buster-slim
COPY --from=builder /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/
ADD https://get.docker.com install_docker.sh
RUN chmod +x install_docker.sh
RUN ./install_docker.sh
RUN rm install_docker.sh

CMD ["docker-compose-updater"]