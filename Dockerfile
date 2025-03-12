# ベースイメージの指定
FROM ubuntu:latest

# 非対話型モードの有効化
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=dumb

# 必要なパッケージの更新とインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    libterm-readline-gnu-perl \
 && rm -rf /var/lib/apt/lists/*

# 以降、必要なファイルのコピーやビルド手順などを記述
