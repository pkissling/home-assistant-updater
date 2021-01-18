FROM --platform=$BUILDPLATFORM rust:1-slim-buster AS cargo-init
ENV USER=root
WORKDIR /code
RUN cargo init
COPY Cargo.toml /code/Cargo.toml
COPY Cargo.lock /code/Cargo.lock
RUN mkdir -p /code/.cargo \
  && cargo vendor > /code/.cargo/config

FROM rust:1-slim-buster as cargo-install
WORKDIR /code
COPY --from=cargo-init /code/.cargo /code/.cargo
COPY --from=cargo-init /code/vendor /code/vendor
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
COPY Cargo.lock /code/Cargo.lock
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo install --offline --path .

FROM debian:buster-slim
RUN apt-get update
ADD https://download.docker.com/linux/debian/dists/buster/pool/stable/armhf/docker-ce-cli_20.10.2~3-0~debian-buster_armhf.deb /tmp/docker-ce-cli.deb
RUN dpkg -i /tmp/docker-ce-cli.deb
RUN rm /tmp/docker-ce-cli.deb
COPY --from=cargo-install /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/docker-compose-updater
ENTRYPOINT ["docker-compose-updater"]
