#!/bin/sh
DATE=$(date +%Y-%m-%d)

if [ ! -d ${PREFIX}/logs/${DATE} ]; then
 mkdir ${PREFIX}/logs/${DATE}
fi

mv ${PREFIX}/logs/error.log ${PREFIX}/logs/${DATE}/error.log
mv ${PREFIX}/logs/access.log ${PREFIX}/logs/${DATE}/access.log

find ${PREFIX}/logs -type d -mtime +4 -exec rm -rf {} \;
# nginx Signal： USR1 -- Reopen the log files
kill -USR1 $(cat /usr/local/ssog/pids/nginx.pid)