#!/bin/sh

for f in $(pwd)/deploy/rules/*.rules.yml
do
	if [ -e "$f" ]
	then
		filename=$( basename "$f" )
		docker run --rm -v $(pwd)/deploy/rules:/rules \
			--entrypoint /bin/promtool prom/prometheus \
			check rules /rules/${filename}
	fi
done
