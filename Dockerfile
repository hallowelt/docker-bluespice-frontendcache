FROM varnish:9

USER root
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && rm -rf /var/lib/apt/lists/*
COPY --chown=varnish:varnish ./root-fs/app /app

USER 1000
ENTRYPOINT ["/app/bin/entrypoint"]
