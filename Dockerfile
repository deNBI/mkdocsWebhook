# --- Build Stage for Webhook ---
# Use Alpine for the builder to maintain consistency
FROM golang:1.27-alpine AS builder

# Install git to fetch dependencies
RUN apk add --no-cache git

# Clone and build webhook as a static binary (CGO_ENABLED=0)
# This ensures it runs on Alpine's musl libc
RUN git clone https://github.com/adnanh/webhook.git /build \
    && cd /build \
    && CGO_ENABLED=0 go build -o webhook .

# --- Final Stage ---
FROM python:3.14-alpine

# Set environment variables
ENV WEBHOOK_URL_PREFIX="wiki/hooks"

# Install system dependencies
# apache2 = Apache, util-linux = for 'flock' in update.sh
RUN apk add --no-cache \
    apache2 \
    git \
    ca-certificates \
    util-linux

# Create required directories
# Alpine's httpd uses /var/www/localhost/htdocs by default,
# but we'll keep your custom paths.
RUN mkdir -p /var/webhook /srv_root/docs /var/www/html/wiki /run/httpd /var/log/httpd

# Copy and install Python dependencies
# We use --no-cache-dir to keep the image slim
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the statically built webhook binary from the builder stage
COPY --from=builder /build/webhook /usr/local/bin/webhook

# Copy your scripts and config files
COPY update.sh /usr/local/bin/update.sh
COPY config/hooks.json /usr/local/bin/hooks.json
# Apache config path changes from /etc/apache2 to /etc/httpd in Alpine
COPY config/apache2.conf /etc/httpd/httpd.conf
COPY start.sh /usr/local/bin/start.sh

# Ensure shell scripts are executable
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/update.sh

# Set container entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]




