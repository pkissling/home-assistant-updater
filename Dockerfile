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
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN export ARCH=$(dpkg --print-architecture) && \
    add-apt-repository \
    "deb [arch=${ARCH}] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"
RUN apt-get update
RUN apt-get install -y docker-ce-cli
COPY --from=cargo-install /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/docker-compose-updater
ENTRYPOINT ["docker-compose-updater"]
