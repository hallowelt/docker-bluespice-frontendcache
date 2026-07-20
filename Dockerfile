FROM varnish:8-alpine

USER root
RUN apk add tzdata
COPY --chown=1000:0 ./root-fs/app /app

RUN chmod -R g=u /app
RUN chown -R 1000:0 /var/lib/varnish
RUN chmod -R g=u /var/lib/varnish

ENV VARNISH_HTTP_PORT=6881

USER 1000
ENTRYPOINT ["/app/bin/entrypoint"]
