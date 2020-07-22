FROM prom/prometheus:v2.19.2

COPY rootfs /

USER root

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
