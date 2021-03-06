FROM docker.io/library/rust:1.58.1 AS build

WORKDIR /src

# Prebuild dependencies
RUN cargo init \
 && mkdir .cargo

COPY Cargo.lock .
COPY Cargo.toml .
RUN cargo vendor > .cargo/config \
 && cargo build --release

# Build full project
COPY . /src
RUN cargo build --release

FROM gcr.io/distroless/cc
COPY --from=build /src/target/release/transmission-proxy /
COPY public /public
CMD ["/transmission-proxy", "--bind", "http://0.0.0.0:3000/transmission", "--serve-root", "/public"]
EXPOSE 3000/tcp
