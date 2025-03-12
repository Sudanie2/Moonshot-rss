# ベースイメージの指定
FROM ubuntu:latest

# 非対話型モードを有効化（debconf の対話を抑制）
ENV DEBIAN_FRONTEND=noninteractive

# 必要なパッケージの更新とインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# 以下、必要に応じてソースコードのコピーやビルドコマンドを記述
# 例:
# COPY . /app
# WORKDIR /app
# RUN pip3 install -r requirements.txt

# コンテナ起動時のコマンド
# CMD ["python3", "rss_generator.py"]
