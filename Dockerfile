ARG PROMETHEUS_VERSION=v2.19.2
FROM prom/prometheus:${PROMETHEUS_VERSION}

USER root
COPY rootfs /
RUN chown -R nobody:nogroup /etc/prometheus

USER nobody

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
