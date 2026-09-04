ARG PYTHON_BASE_IMAGE=python:3.13-slim
  FROM ${PYTHON_BASE_IMAGE}

  USER root

  # Shared runtime dependencies live in this base image so application images do
  # not need to install OS packages and inherit their security fixes directly.
  RUN set -eux; \
      apt-get update -o Acquire::Retries=3; \
      apt-get upgrade --no-install-recommends -y; \
      apt-get install --no-install-recommends -y \
          ca-certificates \
          curl \
          fonts-liberation \
          gnupg \
          libasound2 \
          libatk-bridge2.0-0 \
          libatk1.0-0 \
          libatspi2.0-0 \
          libcairo2 \
          libcups2 \
          libcurl4 \
          libdbus-1-3 \
          libexpat1 \
          libgbm1 \
          libglib2.0-0 \
          libgtk-3-0 \
          libnspr4 \
          libnss3 \
          libpango-1.0-0 \
          libvulkan1 \
          libx11-6 \
          libxcb1 \
          libxcomposite1 \
          libxdamage1 \
          libxext6 \
          libxfixes3 \
          libxkbcommon0 \
          libxrandr2 \
          libssl3t64 \
          mesa-libgallium \
          openssl \
          openssl-provider-legacy \
          unzip \
          wget \
          xdg-utils; \
      mesa_packages="$(dpkg-query -W -f='${binary:Package} ${db:Status-Status}\n' 2>/dev/null \
          | awk '$2 == "installed" && ($1 ~ /^mesa-/ || $1 ~ /^lib.*mesa/ || $1 == "libgbm1") { print $1 }')"; \
      apt-get install --no-install-recommends -y --only-upgrade \
          openssl libssl3t64 openssl-provider-legacy libnss3 $mesa_packages; \
      dpkg --compare-versions "$(dpkg-query -W -f='${Version}' libnss3)" ge "2:3.110-1+deb13u4"; \
      dpkg --compare-versions "$(dpkg-query -W -f='${Version}' openssl)" ge "3.5.7-1~deb13u2"; \
      for mesa_package in $mesa_packages; do \
          dpkg --compare-versions "$(dpkg-query -W -f='${Version}' "$mesa_package")" ge "25.0.7-2+deb13u1"; \
      done; \
      curl -fsSL --retry 3 -o /tmp/google-chrome-stable.deb
      https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
      apt-get install --no-install-recommends -y /tmp/google-chrome-stable.deb; \
      chrome_major="$(google-chrome --product-version | cut -d. -f1)"; \
      curl -fsSL --retry 3 -o /tmp/chrome-versions.json
      https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json; \
      driver_version="$(python -c 'import json, sys; print(json.load(open("/tmp/chrome-versions.json"))["milestones"]
      [sys.argv[1]]["version"])' "$chrome_major")"; \
      curl -fsSL --retry 3 -o /tmp/chromedriver.zip
      "https://storage.googleapis.com/chrome-for-testing-public/${driver_version}/linux64/chromedriver-linux64.zip"; \
      unzip -q /tmp/chromedriver.zip -d /tmp; \
      mv /tmp/chromedriver-linux64/chromedriver /usr/bin/chromedriver; \
      chmod +x /usr/bin/chromedriver; \
      google-chrome --version; \
      chromedriver --version; \
      rm -rf /tmp/google-chrome-stable.deb /tmp/chrome-versions.json /tmp/chromedriver.zip /tmp/chromedriver-linux64; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/*

  ENV CHROME_BIN=/usr/bin/google-chrome \
      CHROMEDRIVER_PATH=/usr/bin/chromedriver

  RUN useradd --create-home --shell /usr/sbin/nologin seluser

  USER seluser
