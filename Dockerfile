FROM rust:latest as builder
RUN apt update && apt install -y cmake
COPY src /build/src
COPY Cargo* /build
WORKDIR /build
RUN mkdir -p bin
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/build/target cargo build && cp /build/target/debug/grpcping-rs ./bin/grpcping-rs

FROM rust:latest
COPY --from=builder /build/bin/grpcping-rs /grpcping-rs
