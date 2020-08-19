#!/bin/sh

for f in $(pwd)/test/*.test.yml
do
	if [ -e "$f" ]
	then
		filename=$( basename "$f" )
		docker run --rm -v $(pwd)/test:/test -v $(pwd)/deploy/rules:/rules \
				--entrypoint /bin/promtool prom/prometheus \
				test rules /test/${filename}
	fi
done
