#!/usr/bin/expect --

set USERNAME_VALUE [lindex $argv 0]
set HOST_IP_VALUE [lindex $argv 1]
set DEST_FILE_PATH_VALUE [lindex $argv 2]
set PASSWORD_VALUE [lindex $argv 3]
set SOURCE_FILE_NAME_VALUE [lindex $argv 4]
set PORT [lindex $argv 5]
  set timeout -1

spawn -noecho /usr/bin/rsync -avz --exclude='*.swx' -u -h --progress $SOURCE_FILE_NAME_VALUE  -e "ssh -p $PORT"  $USERNAME_VALUE@$HOST_IP_VALUE:$DEST_FILE_PATH_VALUE
expect "password:" {
  send -- "$PASSWORD_VALUE\r" }

  expect "]# " {
  send -- "exit\r" }

 


