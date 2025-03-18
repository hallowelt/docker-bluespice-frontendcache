FROM varnish:7-alpine

COPY root-fs/etc/varnish/default.vcl /etc/varnish/default.vcl