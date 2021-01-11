# fetch the vendor with the builder platform to avoid qemu issues
FROM --platform=$BUILDPLATFORM rust:1-slim-buster AS cargo-init
ENV USER=root
WORKDIR /code
RUN cargo init
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
RUN mkdir -p /code/.cargo \
  && cargo vendor > /code/.cargo/config

FROM --platform=$BUILDPLATFORM rust:1-slim-buster as cargo-install
WORKDIR /code
COPY --from=cargo-init /code/.cargo /code/.cargo
COPY --from=cargo-init /code/vendor /code/vendor
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo install --offline --path .

FROM debian:buster-slim
COPY --from=cargo-install /usr/local/cargo/bin/docker-compose-updater /usr/local/bin/
ADD https://get.docker.com /tmp/install_docker.sh
RUN chmod +x /tmp/install_docker.sh
RUN /tmp/install_docker.sh
RUN rm /tmp/install_docker.sh
CMD ["docker-compose-updater"]