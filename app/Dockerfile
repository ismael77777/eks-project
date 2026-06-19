# Small, official Python base image. The -slim variant keeps the image
# lean (fewer packages = smaller attack surface and faster pulls).
FROM python:3.12-slim

# Where the app lives inside the container.
WORKDIR /app

# Copy dependencies first and install them. Doing this BEFORE copying the
# rest of the code lets Docker cache the install layer, so code changes
# don't force a re-install on every build.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the application code.
COPY app.py .

# Document the port the app listens on.
EXPOSE 5000

# Run as a non-root user for security (don't run containers as root).
RUN useradd --create-home appuser
USER appuser

# Container-level health check (complements the Kubernetes probes).
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/healthz')" || exit 1

# Start the app.
CMD ["python", "app.py"]
