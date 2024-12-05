# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WHISPER_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

ENV HOME=/config \
  DEBIAN_FRONTEND="noninteractive" \
  TMPDIR="/run/whisper-temp"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
    python3-dev \
    python3-venv && \
  if [ -z ${WHISPER_VERSION+x} ]; then \
    WHISPER_VERSION=$(curl -sX GET "https://api.github.com/repos/rhasspy/wyoming-faster-whisper/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    git+https://github.com/rhasspy/wyoming-faster-whisper@${WHISPER_VERSION} && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential \
    git \
    python3-dev && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

COPY root/ /

VOLUME /config

EXPOSE 10300
