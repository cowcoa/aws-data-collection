#!/bin/bash

i=1

generate_post_data()
{
cat <<EOF
{"id":$i,"login":"cow","password":"123"}
EOF
}

echo $(generate_post_data) &>> /tmp/crontab_test.log
# sed "s/MACRO_HTTP_PORT/8088/g" nginx.conf.template > nginx.conf