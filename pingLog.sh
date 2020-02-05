#!/bin/bashi
# ping script which log the packets analysis in log file
# Mohit Mehral

log_file=`date +%Y%m%d_ping.log`
if [ ! -f /tmp/$log_file ];then ### create if file not existings.
        touch /tmp/$log_file
  fi
/bin/ping -qn -W4 -c2 10.152.0.2 2>&1|xargs -iX /bin/date +"%Y-%m-%d %H:%M:%S X" >> "/tmp/$log_file"
