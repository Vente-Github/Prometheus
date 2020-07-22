FROM prom/prometheus:v2.19.2

USER root
COPY rootfs /
RUN chown -R nobody:nogroup /etc/prometheus

USER nobody

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
