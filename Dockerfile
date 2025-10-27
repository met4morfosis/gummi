# Build stage
FROM rust:1.90.0 AS builder
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY gummi-bot/Cargo.toml gummi-bot/
COPY gummi-db/Cargo.toml gummi-db/
COPY gummi-cache/Cargo.toml gummi-cache/
COPY gummi-metrics/Cargo.toml gummi-metrics/
COPY gummi-commands/Cargo.toml gummi-commands/

RUN mkdir -p gummi-bot/src gummi-db/src gummi-cache/src && \
    echo 'fn main() {}' > gummi-bot/src/main.rs && \
    echo '' > gummi-db/src/lib.rs && \
    echo '' > gummi-cache/src/lib.rs && \
    echo '' > gummi-metrics/src/lib.rs && \
    echo '' > gummi-commands/src/lib.rs


RUN cargo fetch

COPY . .

RUN cargo build --release -p gummi-bot

# Runtime stage
FROM debian:bookworm-slim
WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/gummi-bot /usr/local/bin/gummi-bot

CMD ["gummi-bot"]
