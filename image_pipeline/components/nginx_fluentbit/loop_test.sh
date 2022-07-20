#!/bin/bash

i=1

generate_post_data()
{
cat <<EOF
{"id":$i,"login":"cow","password":"123111"}
EOF
}

while [ "$i" -ne 0 ]
do
   echo $(generate_post_data);
   curl -d "$(generate_post_data)" -XPOST -H "content-type: application/json" http://127.0.0.1:8088/log
   i=$((i+1))
   sleep 1
done
