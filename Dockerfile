# Use a stable Python base image (Debian 12 based)
FROM python:3.14-slim

# Set environment variables
ENV WEBHOOK_URL_PREFIX="wiki/hooks"

# Install system dependencies
RUN apt update && apt install -y --no-install-recommends \
    unzip apache2 build-essential python3-dev python3-pip \
    python3-setuptools python3-wheel python3-cffi libcairo2 \
    libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf-2.0-0 \
    libffi-dev shared-mime-info git wget curl ca-certificates \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
ADD requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install webhook binary
RUN wget -qO- https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz \
    | tar xzv --strip 1 -C /usr/local/bin

# Create required directories
RUN mkdir -p /var/webhook /srv_root/docs /var/www/html/wiki

# Copy your scripts and config files
ADD update.sh /usr/local/bin/update.sh
COPY config/hooks.json /usr/local/bin/hooks.json
COPY config/apache2.conf /etc/apache2/apache2.conf
ADD start.sh /usr/local/bin/start.sh

# Ensure shell scripts are executable
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/update.sh

# Set container entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]

