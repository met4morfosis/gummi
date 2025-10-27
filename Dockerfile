# Build stage
FROM rust:1.90.0 AS builder
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY gummi-bot/Cargo.toml gummi-bot/
COPY gummi-db/Cargo.toml gummi-db/
COPY gummi-cache/Cargo.toml gummi-cache/
COPY gummi-metrics/Cargo.toml gummi-metrics/
COPY gummi-commands/Cargo.toml gummi-commands/

RUN for crate in gummi-bot gummi-db gummi-cache gummi-metrics gummi-commands; do \
    mkdir -p $crate/src; \
    if [ "$crate" = "gummi-bot" ]; then \
    echo 'fn main() {}' > $crate/src/main.rs; \
    else \
    echo '' > $crate/src/lib.rs; \
    fi \
    done

RUN cargo fetch

COPY . .

RUN cargo build --release -p gummi-bot

# Runtime stage
FROM debian:bookworm-slim
WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/gummi-bot /usr/local/bin/gummi-bot

CMD ["gummi-bot"]
