# --- Build Stage for Webhook ---
FROM golang:1.27.4-alpine3.24@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS builder

RUN apk upgrade --no-cache && apk add --no-cache git

# Build a statically linked binary without CGO dependencies.
RUN git clone https://github.com/adnanh/webhook.git /build \
    && cd /build \
    && CGO_ENABLED=0 go build -o webhook .


# --- Final Stage ---
FROM python:3.15.2-alpine3.24@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd

ENV WEBHOOK_URL_PREFIX="wiki/hooks"

# Install runtime dependencies.
RUN apk upgrade --no-cache && apk add --no-cache \
    apache2 \
    git \
    ca-certificates \
    util-linux

# Create required directories.
RUN mkdir -p \
    /var/webhook \
    /srv_root/docs \
    /var/www/html/wiki \
    /run/apache2 \
    /var/log/apache2

RUN git config --global --add safe.directory /srv_root/docs

# Install Python dependencies.
COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps build-base && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apk del .build-deps

# Copy webhook binary.
COPY --from=builder /build/webhook /usr/local/bin/webhook

# Copy scripts and configuration.
COPY update.sh /usr/local/bin/update.sh
COPY config/hooks.json /usr/local/bin/hooks.json
COPY config/apache2.conf /etc/apache2/httpd.conf
COPY start.sh /usr/local/bin/start.sh

RUN chmod +x \
    /usr/local/bin/start.sh \
    /usr/local/bin/update.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
