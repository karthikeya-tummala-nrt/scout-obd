FROM --platform=linux/arm64 ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone -b stable https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

WORKDIR /app
COPY . .

RUN flutter --version
RUN flutter pub get
RUN flutter build linux --release

VOLUME /build/linux/arm64/release/bundle
