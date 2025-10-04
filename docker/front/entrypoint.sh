#!/bin/sh

eval "cat <<EOF
$(<"/runtime-config.json.template")
EOF" > "./runtime-config.json"

nginx -g 'daemon off;'
