############################sftp_expect.sh###########################
#!/usr/bin/expect --

set HOST [lindex $argv 0]
set USER [lindex $argv 1]
set PASSWD [lindex $argv 2]
set FILE [lindex $argv 3]
set PORT [lindex $argv 4]
set timeout -1



spawn -noecho sftp -oPort=$PORT $USER@$HOST

  expect "*?assword: " {
  send -- "${PASSWD}\r" }

  expect "sftp>" {
  send -- "get $FILE\r" }

  expect "sftp>" {
  send -- "bye\r" }
#############################################################

#Calling ::: ./sftp_expect.sh "${SERVER_IP_ARRAY[$j]}" "${SERVER_USERNAME_ARRAY[$j]}" "${SERVER_PASSWORD_ARRAY[$j]}" #"${SERVER_PATH_ARRAY[$j]}/Final-${SERVER_IP_ARRAY[$j]}-$CUREENT_DATE.log" "${SERVER_PORT_ARRAY[$j]}" 2>&1 1> temp_ftplogs.txt
