#!/bin/sh -e

CONFIG_PATH=/etc/prometheus
PROMETHEUS_TEMPLATE_FILENAME="${CONFIG_PATH}/prometheus.yml.tmpl"

if [ ${JOBS:+x} ]
then
	for job in $(echo "${JOBS}" | tr ',' ' ')
	do
		echo "adding job ${job}"

		jobParams=$(echo "${job}" | sed -r 's/(.*):([[:digit:]]+)(\/[^;]*)?(;([[:digit:]]+)?)?(;([[:digit:]]+)?)?$/\1 \2 \3 \5 \7/')
		serviceName=$(echo "${jobParams}" | cut -d " " -f1)
		if echo "${serviceName}" | grep -qvE "\."
		then
			serviceName=$(echo "tasks.${serviceName}")
		fi
		port=$(echo "${jobParams}" | cut -d " " -f2)
		metricsPath=$(echo "${jobParams}" | cut -d " " -f3)
		scrapeInterval=$(echo "${jobParams}" | cut -d " " -f4)
		scrapeTimeout=$(echo "${jobParams}" | cut -d " " -f5)

		cat >> "${PROMETHEUS_TEMPLATE_FILENAME}" <<EOF

  - job_name: '${serviceName}'
    ${scrapeInterval:+scrape_interval: ${scrapeInterval}s}
    ${scrapeTimeout:+scrape_timeout: ${scrapeTimeout}s}
    ${metricsPath:+metrics_path: '${metricsPath}'}
    dns_sd_configs:
      - names:
          - '${serviceName}'
        type: 'A'
        port: ${port}
EOF
	done
fi

if ls ${CONFIG_PATH}/*.rules.yml > /dev/null 2> /dev/null
then
	echo "Adding rules file"
	echo "rule_files:" >> "${PROMETHEUS_TEMPLATE_FILENAME}"

	for f in ${CONFIG_PATH}/*.rules.yml
	do
		if [ -e "${f}" ]
		then
			filename=$( basename "${f}" )
			echo "adding rules ${filename}"
			echo '  - "'${filename}'"' >> "${PROMETHEUS_TEMPLATE_FILENAME}"
		fi
	done
fi

mv "${PROMETHEUS_TEMPLATE_FILENAME}" "${CONFIG_PATH}/prometheus.yml"

cat "${CONFIG_PATH}/prometheus.yml"

# Force all args into prometheus
if [[ "$1" = 'prometheus' ]]; then
  shift
fi

exec prometheus --web.console.libraries="/usr/share/prometheus/console_libraries" \
	  --web.console.templates="/usr/share/prometheus/consoles" \
	  --web.external-url="${WEB_EXTERNAL_URL:-http://localhost:${PORT}}" \
	  --web.route-prefix="${WEB_ROUTE_PREFIX:-/}" \
	  --config.file="${CONFIG_FILE:-/etc/prometheus/prometheus.yml}" \
	  --storage.tsdb.path="${STORAGE_TSDB_PATH:-/prometheus}" \
      --storage.tsdb.retention.time="${STORAGE_TSDB_RETENTION_TIME:-30d}" \
      --storage.tsdb.retention.size="${STORAGE_TSDB_RETENTION_SIZE:-8GB}" \
      --storage.tsdb.wal-compression \
      "$@"