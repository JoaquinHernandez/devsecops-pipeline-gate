cat << 'EOF' > Dockerfile
# --- Stage 1: Build & Dependency Resolution ---
FROM python:3.11-slim-bookworm AS builder

WORKDIR /build

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libffi-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# --- Stage 2: Hardened Non-Root Runtime ---
FROM python:3.11-slim-bookworm AS runtime

WORKDIR /app

# Provision non-root system group and user
RUN groupadd -g 65532 appgroup && \
    useradd -u 65532 -g appgroup -s /usr/sbin/nologin -d /app appuser

# Extract pre-compiled dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appgroup app/ /app/

# Remove default debugging and lateral movement utilities
RUN rm -rf /bin/nc /bin/netcat /usr/bin/curl /usr/bin/wget /usr/bin/apt* /var/lib/apt/*

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER 65532:65532

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=2)" || exit 1

ENTRYPOINT ["python3", "/app/main.py"]
EOF
