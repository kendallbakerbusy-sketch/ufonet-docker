FROM python:3.11-slim

# Metadata
LABEL maintainer="Docker UFONet Build"
LABEL description="UFONet - Denial of Service Toolkit"
LABEL version="1.0"

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3-dev \
    python3-pip \
    libcurl4-openssl-dev \
    libssl-dev \
    libgeoip1 \
    libgeoip-dev \
    build-essential \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone UFONet repository
RUN git clone https://github.com/epsylon/ufonet.git /app/ufonet

# Set working directory to ufonet
WORKDIR /app/ufonet

# Upgrade pip
RUN python3 -m pip install --upgrade pip --no-warn-script-location --root-user-action=ignore

# Install pycurl with specific options
RUN python3 -m pip install pycurl --upgrade --root-user-action=ignore

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir \
    pycurl \
    GeoIP \
    python-geoip \
    pygeoip \
    requests \
    python-whois \
    scapy \
    pycryptodomex \
    duckduckgo-search \
    --root-user-action=ignore

# Make ufonet executable
RUN chmod +x /app/ufonet/ufonet

# Create volume mount point for botnet data
VOLUME ["/app/ufonet/botnet", "/app/ufonet/data"]

# Set environment variable for Python
ENV PYTHONUNBUFFERED=1

# Default command - show help
CMD ["python3", "ufonet", "--help"]
