# Docker Official の Rustイメージを使う
FROM rust:latest AS builder

# /todo でビルドを行う
WORKDIR /rust-todo-app

# Cargo.tomlのみ先にイメージにコピー
COPY Cargo.toml Cargo.toml

# ビルドするために何もしないソースコードを入れておく
RUN mkdir src
RUN echo "fn main() {}" > src/main.rs

# 上記で作成したコードと依存クレートをビルドする
RUN cargo build --release

# アプリケーションのコードをイメージにコピー
COPY ./src ./src
COPY ./templates ./templates

# 先ほどビルドした生成物のうち、アプリケーションのもののみを削除する
RUN rm -f target/release/deps/todo*

# 改めてビルド
RUN cargo build --release


# ここから実行用のイメージを作成
FROM debian:buster-slim

# ビルド時に作成したイメージからコピー
COPY --from=builder /rust-todo-app/target/release/rust-todo-app /usr/local/bin/todo

# コンテナ起動時にWebアプリを実行する
CMD ["rust-todo-app"]
