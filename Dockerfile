FROM python:3.13-slim

USER root

RUN set -eux; \
    apt-get update; \
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
        openssl \
        openssl-provider-legacy \
        unzip \
        wget \
        xdg-utils; \
    curl -fsSL --insecure -o /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
    apt-get install --no-install-recommends -y /tmp/google-chrome-stable.deb; \
    chrome_major="$(google-chrome --product-version | cut -d. -f1)"; \
    curl -fsSL --insecure -o /tmp/chrome-versions.json https://googlechromelabs.github.io/chrome-for-testing/latest-versions-per-milestone-with-downloads.json; \
    driver_version="$(python -c 'import json, sys; data = json.load(open("/tmp/chrome-versions.json")); print(data["milestones"][sys.argv[1]]["version"])' "$chrome_major")"; \
    curl -fsSL --insecure -o /tmp/chromedriver.zip "https://storage.googleapis.com/chrome-for-testing-public/${driver_version}/linux64/chromedriver-linux64.zip"; \
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

RUN useradd -m localUser

USER localUser
