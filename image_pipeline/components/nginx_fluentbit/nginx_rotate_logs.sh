#!/bin/bash

mv /var/log/nginx/postdata.log /var/log/nginx/postdata.log.0
kill -USR1 `cat /run/nginx.pid`
sleep 1
