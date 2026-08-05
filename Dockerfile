# --- Build Stage for Webhook ---
FROM golang:1.24-bookworm AS builder

# Install git to fetch dependencies
RUN apt-get update && apt-get install -y git

# Clone and build webhook
RUN git clone https://github.com/adnanh/webhook.git /build \
    && cd /build \
    && make build

# --- Final Stage ---
FROM python:3.12-slim-bookworm

# Set environment variables
ENV WEBHOOK_URL_PREFIX="wiki/hooks"

# Install system dependencies and upgrade for security patches
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    apache2 \
    git \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the freshly built webhook binary from the builder stage
COPY --from=builder /build/webhook /usr/local/bin/webhook

# Create required directories
RUN mkdir -p /var/webhook /srv_root/docs /var/www/html/wiki

# Copy your scripts and config files
COPY update.sh /usr/local/bin/update.sh
COPY config/hooks.json /usr/local/bin/hooks.json
COPY config/apache2.conf /etc/apache2/apache2.conf
COPY start.sh /usr/local/bin/start.sh

# Ensure shell scripts are executable
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/update.sh

# Set container entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]


