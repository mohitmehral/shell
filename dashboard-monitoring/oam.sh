#!/bin/bash
#=== Plugin Name ===
#Contributors: (mohitmehral@gmail.com )
#Tags: linux system stats send to mysql db
#Requires at least: no specific rpm required
#Stable tag: 1.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#== Description ==
#his script use for system stats send to mysql db for logging / UI based dashboard.
#

#== how to run the script
#Step 1: change variable's to use for mysql queries
#Step 2: cron this in every 5 min frequency
#step 3. run onm.sh
##################################################


#Variables to use for mysql queries
MIS_USER=root
MIS_PASS=rnd
MIS_DB=ussd_gw
HOST=10.64.1.144
LOG_DIR=logs/
SERVER_ID=2
DSK=0
DSK1=0
DSK2=0

#ddtruncate table data

#################################OAM Script
DT=`date +%F,%H:%M`
IP=`/sbin/ifconfig eth0|grep "inet addr:"|tr -s " " |/usr/bin/cut -d " " -f3|/usr/bin/cut -d ":" -f2`
CPU_INFO="Intel(R) Xeon(R),Quard Core,CPU@ 2.00GHz"
#CPU_SPEED=`hdparm -tT /dev/sda |grep "Timing cached reads:"|cut -d ":" -f2| cut -d "=" -f2`
CPU_SPEED="5.46GB RW"
#TOT_RAM=`free -m|grep Mem:|tr -s " "|cut -d ":" -f2|cut -d " " -f2|cut -c1,2`
TOT_RAM="24GB"
USED_RAM=`/usr/bin/free -m|grep Mem:|tr -s " "|/usr/bin/cut -d ":" -f2|/usr/bin/cut -d " " -f3`
#TOT_DISK1=`fdisk -l|grep "/dev/sda:"|cut -d ":" -f2|cut -d "," -f1|cut -d " " -f2`
#TOT_DISK2=`fdisk -l|grep "/dev/sdb:"|cut -d ":" -f2|cut -d "," -f1|cut -d " " -f2`
#TOT_DISK=`expr $TOT_DISK1 + $TOT_DISK2`
UPTIME=`/usr/bin/uptime |/usr/bin/cut -d " " -f4,5| /usr/bin/cut -d "," -f1`
CPU_USER=`/usr/bin/mpstat | tr -s " " | grep "all" | /usr/bin/cut -d " " -f4`
CPU_SYS=`/usr/bin/mpstat | tr -s " " | grep "all" | /usr/bin/cut -d " " -f6`
CPU_IDLE=`/usr/bin/mpstat | tr -s " " | grep "all" | /usr/bin/cut -d " " -f11`
TOT_DISK=346
for DSK in `/bin/df -m | tr -s " " | /usr/bin/cut -d " " -f 3 | tail -n +2`
do
	DSK1=0
	DSK1=`expr $DSK`
	DSK2=`expr $DSK1 + $DSK2`
done
USED_DISK=`expr $DSK2 / 1024`

#echo "Date Time : $DT "
#echo "Server IP : $IP "
#echo "CPU_INFO 	: 4 - $CPU_INFO "
#echo "CPU_SPEED : $CPU_SPEED "
#echo "TOT_RAM 	: $TOT_RAM "
#echo "USED_RAM 	: $USED_RAM "
#echo "TOT_DISK  : $TOT_DISK "
#echo "USED_DISK : $USED_DISK "
#echo "UPTIME	: $UPTIME "
#echo "CPU_USER  : $CPU_USER "
#echo "CPU_SYS	: $CPU_SYS "
#echo "CPU_IDLE	: $CPU_IDLE "
#
#Insert the above calulated values to ussd_gw.tbl_oam_system_stats
mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -e "delete from tbl_oam_system_stats where server_id = '$SERVER_ID'"
mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -s -s -e "insert into tbl_oam_system_stats(datetime,server_id,ip_addr,cpu,cpu_speed,tot_ram,used_ram,tot_disk,used_disk,uptime,cpu_user,cpu_sys,cpu_idle) values ('$DT','$SERVER_ID','$IP','$CPU_INFO','$CPU_SPEED','$TOT_RAM','$USED_RAM MB','$TOT_DISK','$USED_DISK','$UPTIME','$CPU_USER','$CPU_SYS','$CPU_IDLE');"
echo mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -s -s -e "insert into tbl_oam_system_stats(datetime,server_id,ip_addr,cpu,cpu_speed,tot_ram,used_ram,tot_disk,used_disk,uptime,cpu_user,cpu_sys,cpu_idle) values ('$DT','$SERVER_ID','$IP','$CPU_INFO','$CPU_SPEED','$TOT_RAM','$USED_RAM MB','$TOT_DISK','$USED_DISK','$UPTIME','$CPU_USER','$CPU_SYS','$CPU_IDLE');" > logs/mm.txt
####################################################################
###########################Process STATS
mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -e "delete from tbl_oam_process_stats where server_id = '$SERVER_ID';"

#####Taking input from Previous script#######
if [[ $# == 1 ]];then
  INPUT=$1
  check=`echo  $INPUT | grep -a "^-a.*" | wc -l`
    if [[ $check == 1 ]];then
       check_parameter_input=`echo $INPUT | awk -F"-a" '{print $2}'`
    fi
fi
############# READ PROCESS NAME FROM BINARY FILE##############
cat binaries/${check_parameter_input}|while read binary
             do
                # Extract first character of every line
                       first=`echo $binary | cut -c1`
                 # If line is empty do nothing
                       if [ -z $first ]
                        then
                                continue
                        fi

                 # If line starts with a '#' do nothing
                 if [ $first = \# ]
                 then
                         continue

                  # Else test for the command
                 else

  			process=`echo $binary|cut -d '~' -f1`
                        process_run=`echo $binary|cut -d '~' -f22`
                         ##### CHECK PROCESS RUNNING##########
                        ps -C $process &> /dev/null
                        if [ $? -ne 0 ]
                        then
			#echo "Binary not running $binary"
			mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -s -s -e "insert into tbl_oam_process_stats(datetime,server_id,process_name,status,queue_pendency,start_date) values ('$DT','$SERVER_ID','$process','2','0','$DT');"
			else
			mysql -h$HOST -u $MIS_USER -p$MIS_PASS $MIS_DB -s -s -e "insert into tbl_oam_process_stats(datetime,server_id,process_name,status,queue_pendency,start_date) values ('$DT','$SERVER_ID','$process','1','0','$DT');"
			#echo "Binary  running $binary"
			fi
	fi
done
