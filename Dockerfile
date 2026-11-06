FROM varnish:9

USER root
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && rm -rf /var/lib/apt/lists/*
COPY --chown=1000:0 ./root-fs/app /app
RUN chown -R 1000:0 /var/lib/varnish && \
    chmod -R g=u /app /var/lib/varnish

# Build info: value of build arg BUILDINFO, falls back to the UTC build timestamp (YmdHis)
ARG BUILDINFO
RUN mkdir -p /image && echo "${BUILDINFO:-$(date -u +%Y%m%d%H%M%S)}" > /image/BUILDINFO

ENV VARNISH_HTTP_PORT=6881

USER 1000
ENTRYPOINT ["/app/bin/entrypoint"]

