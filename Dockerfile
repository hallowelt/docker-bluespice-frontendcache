FROM varnish:7-alpine

USER root
COPY --chown=varnish:varnish ./root-fs/app /app

USER varnish
ENTRYPOINT ["/app/bin/init"]