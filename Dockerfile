FROM varnish:8-alpine

USER root
RUN apk add tzdata
COPY --chown=varnish:varnish ./root-fs/app /app

USER 1000
ENTRYPOINT ["/app/bin/entrypoint"]
