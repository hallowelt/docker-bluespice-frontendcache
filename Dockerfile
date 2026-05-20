FROM varnish:8-alpine

USER root
COPY --chown=varnish:varnish ./root-fs/app /app

USER 1000
ENTRYPOINT ["/app/bin/entrypoint"]
