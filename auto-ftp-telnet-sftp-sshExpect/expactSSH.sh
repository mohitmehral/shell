!/usr/bin/expect -f
#From Linuxaria.com the script is licensed under GNU GPL version 2.0 or above 
# Expect script to give username, password and IP/port 
# to connect to a remote ssh server and execute command.
# This script needs five argument :
# username = Unix username on the remote machine
# password = Password of username you have provided.
# server = IP Address or hostname of the remote server.
# port = Port of the SSH server on the remote server, usually 22
# program = Complete path to the command you want to run
 
#As first thing we check to have 5 arguments:
if {[llength $argv] != 5} {
 
# We give a message so the user know our syntax:
puts "usage: ssh.exp username password server port program"
 
#We exit with return code = 1
exit 1
}
 
# Now we set variables in expect, note:  [lrange $argv 0 0 =$1 the first parameter, and so on.
 
set username [lrange $argv 0 0]
set password [lrange $argv 1 1]
set server [lrange $argv 2 2]
set port [lrange $argv 3 3]
set program [lrange $argv 4 4]
 
#The value of timeout must be an integral number of seconds. Normally timeouts are nonnegative, but the special case of -1 signifies that expect #should wait forever.
set timeout 60
 
# Now we can connect to the remote server/port with our username and password, the command spawn is used to execute another process:
spawn ssh -p $port $username@$server $program
match_max 100000
 
# Now we expect to have a request for password:
expect "*?assword:*"
 
# And we send our password:
send -- "$password\r"
 
# send blank line (\r) to make sure we get back to cli
send -- "\r"
 
#We have gave our "program" and now we expect that the remote server close the connection:
expect eof