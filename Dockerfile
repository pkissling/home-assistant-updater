FROM rust:1-slim-buster as builder
WORKDIR /code
COPY src/ /code/src/
COPY Cargo.toml /code/Cargo.toml
RUN rustup update nightly
RUN rustup override set nightly
RUN cargo build
CMD ["cargo", "run"]