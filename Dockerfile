# --- Build Stage for Webhook ---
FROM golang:1.27.3-alpine3.24@sha256:d200d2dd76b03a99b52651fd1325aff7dcd35422c35c01bac56571b0507f3deb AS builder

RUN apk upgrade --no-cache && apk add --no-cache git

# Build a statically linked binary without CGO dependencies.
RUN git clone https://github.com/adnanh/webhook.git /build \
    && cd /build \
    && CGO_ENABLED=0 go build -o webhook .


# --- Final Stage ---
FROM python:3.15.1-alpine3.24@sha256:54448f67d7c31c39e5cdd3ea2d6382395ce142806c284425f8e897d78a0465b3

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
