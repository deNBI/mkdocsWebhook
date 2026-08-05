# Use a stable Python base image (Debian 12 Bookworm slim)
FROM python:3.12-slim-bookworm

# Set environment variables
ENV WEBHOOK_URL_PREFIX="wiki/hooks"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    git \
    wget \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install webhook binary
RUN wget -qO- https://github.com/adnanh/webhook/releases/download/2.8.3/webhook-linux-amd64.tar.gz \
    | tar xzv --strip 1 -C /usr/local/bin

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

