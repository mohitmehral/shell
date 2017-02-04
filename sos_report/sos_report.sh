#!/bin/bash
####################################################################################################
##=== sos_report.sh ===
#Contributors: (mohitmehral@gmail.com )
#Tags: linux , smsc, ussd, other services
#Requires at least: no specific rpm required
#Stable tag: 2.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#==description===== 
#This script fetch system report, db structure, used config files and other product related details
#               This script output/report helpfull to identify the issue in remote system.
#=== Revision History ===
#
# Date        Name              Reason
# ----        ----              ------
# 06-03-2012  Mohit Mehral      common script for all products
###################################################################################################

#
pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

cd $BASE_PATH

print_help()
{
    echo ""
    echo "Please give correct argument which start with '-a' can be:"
    echo "Please don't put any space between -a and argument"
    echo "1)ussd"
    echo "2)smsc"
    echo "3)common"
    echo "4)other"
    echo "e.g [#]./sos_report.sh -aussd"
    exit
}
######## READ PARAMETER FROM INPUT###########
if [[ $# == 1 ]];then
  INPUT=$1
  check=`echo  $INPUT | grep -a "^-a.*" | wc -l`
    if [[ $check == 1 ]]
       then
       check_parameter_input=`echo $INPUT | awk -F"-a" '{print $2}'`
       $check_parameter_input &> /dev/null
       if [ $? -ne 0 ]
        then
        echo "Processing for $check_parameter_input ..."
       else
           print_help
       fi
    else
      print_help
    fi
else
    print_help
fi
clear
##############################################
DATE=`date +%Y-%m-%d`
log_file_path="$SCRIPT_LOGS/${DATE}-"`basename $0 .sh`".log"
hostIp=`grep IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0|awk -F= '{print $2}'`
Date=`date +%Y%m%d%H%M`
Sos_dir="/tmp/$Date""_${check_parameter_input}""_SOS-REPORT_$hostIp/"
log_file="$Date""_${check_parameter_input}""_SOSreport_$hostIp.txt" 
product="ussd"
txt_file="/tmp/temp1.txt"
txt_file1="/tmp/temp2.txt"
PID="/tmp/pid.txt"
SIUFTP="siuftp"
DB_username="root"
DB_password="rnd"
############################################
pwd="$(pwd)"
echo "$pwd"

echo -n " Enter username for siu ftp [$SIUFTP] ::" ;read a
if [ ${#a} -gt 0 ]
then
	echo
else
	a=$SIUFTP
	echo $a
fi
echo -n " Enter password for siu ftp ::" ;read b
        echo $b

echo -n " Enter MYSQL DB username [$DB_username] ::" ;read c
if [ ${#c} -gt 0 ]
then
        echo
else
        c=$DB_username
        echo $c
fi
echo -n " Enter MYSQL DB $DB_username user password[rnd]  ::" ;read d
        echo $d

smsc_sos()
{
	septel="/home/smsc/septel"
	DB_cfg="$Apache/webapps/CampaignManager/WEB-INF/classes/com/cellebrum/campaginManager/DB.cfg"
	echo "************************ ./gctloat -t1 **************************">>$Sos_dir$log_file
	$septel/gctload -t1>>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	$septel/gctload -v>>$Sos_dir$log_file
	$septel/map_lnx6 -v>>$Sos_dir$log_file
	$septel/tcp_lnx6 -v>>$Sos_dir$log_file
	$septel/sccp_lnx6 -v>>$Sos_dir$log_file
	$septel/m3ua_lnx6 -v>>$Sos_dir$log_file
	echo "************************ ./gctloat -t2 **************************">>$Sos_dir$log_file
	$septel/gctload -t2>>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** SIU DETAILS*****************************************************">>$Sos_dir$log_file
	cat $septel/restart.sh |grep rsicmd|awk -F" " '{print $5, $6}'>>$Sos_dir$log_file
	if [ $? -eq 0 ];then
        	SIU_IP=`cat $septel/restart.sh |grep rsicmd|awk -F" " '{print $5}'`
		ftp -vn <<config
		open $SIU_IP
		user $a $b
		get config.txt
		close
config
		mv config.txt $Sos_dir
		echo "*****************************CONFIG FILE COPIED FROM SIU **************************************">>$Sos_dir$log_file
	else
		continue;
	echo "!!!!!!!!!!!!!! Unable to login to SIU[$SIU_IP]!!!!!!!!!!!!!!!!!!!!!!! " >>$Sos_dir$log_file
	fi
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file

	if [ -d $septel/p2p/alerts ];then
		cd $septel/p2p/alerts
		cp -f *.sh $Sos_dir"scripts"
		if [ $? -ne 0 ];then
			echo >>$Sos_dir$log_file
			echo >>$Sos_dir$log_file
			echo "**********************ALERTS SCRIPTS NOT Found[${septel}/p2p/alerts] **********************************">>$Sos_dir$log_file
		else
			echo >>$Sos_dir$log_file
			echo >>$Sos_dir$log_file
			echo "**********************ALERTS SCRIPTS COPIED FROM [${septel}/p2p/alerts] **********************************">>$Sos_dir$log_file	
		fi

	fi
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo `cp $septel/p2p/smsc.cfg $septelp2p/restart.sh "$Sos_dir"septel`>>$Sos_dir$log_file
	sh $septel/p2p/monitor.sh>> $Sos_dir$log_file
	cp $septel/config.txt $Sos_dir"septel"
	cp $septel/system.txt $Sos_dir"septel"
	if [ $? -ne 0 ];then
        	
echo >>$Sos_dir$log_file
	        echo "**********************SYSTEM.TXT NOT COPIED **********************************">>$Sos_dir$log_file
	else
        	echo >>$Sos_dir$log_file
	        echo "**********************SYSTEM.TXT COPIED **********************************">>$Sos_dir$log_file
	fi
	cp $septel/restart.sh $septel/*.ms7 $Sos_dir"septel"
	if [ $? -ne 0 ];then
	        echo >>$Sos_dir$log_file
        	echo "**********************MS7 FILES NOT COPIED **********************************">>$Sos_dir$log_file
	else
        	echo >>$Sos_dir$log_file
	        echo "**********************MS7 FILES COPIED **********************************">>$Sos_dir$log_file
	fi
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	service mysqld status>>$Sos_dir$log_file
	cp $DB_cfg $Sos_dir
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** MEMORY MAPPING FOR MYSQLD **********************************">>$Sos_dir$log_file
	My_pid=`ps -C mysqld -o pid=`
	echo "My_pid is $My_pid"
	pmap -x $My_pid>>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** DATABASE BLOCK **********************************">>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** TBL_FILEPATH        **********************************">>$Sos_dir$log_file
	mysql -u$c -p$d CampaignManager -e "select count(1) as count_filepath from tbl_filepath">>$Sos_dir$log_file
	mysql -u$c -p$d CampaignManager -e "select * from tbl_filepath where date_format(DateTime,'%Y-%m-%d')=curdate()">>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** TBL_SMS_PENDING     **********************************">>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	mysql -u$c -p$d CampaignManager -e "select count(1) as count_pending from tbl_sms_pending ">>$Sos_dir$log_file
	mysql -u$c -p$d CampaignManager -e "select * from tbl_sms_pending limit 10">>$Sos_dir$log_file
	echo "*********************** MIS BLOCK **********************************">>$Sos_dir$log_file

	echo "                    TBL_MIS(CURRENT DAY HOURLY)                      ">>$Sos_dir$log_file

	mysql -u$c -p$d MIS -e "select hour,filename,sum(tot_sent_count),sum(tot_success),sum(tot_prm_fail),sum(tot_switchedoff),sum(tot_other_error) from MIS.tbl_mis where date_format(date_time,'%Y-%m-%d')=curdate() group by hour,filename order by hour">>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo "*********************** TBL_MIS(PREVIOUS DAY HOURLY)   **********************************">>$Sos_dir$log_file

	mysql -u$c -p$d MIS -e "select hour,filename,sum(tot_sent_count),sum(tot_success),sum(tot_prm_fail),sum(tot_switchedoff),sum(tot_other_error) from MIS.tbl_mis where date_format(date_time,'%Y-%m-%d')=date_Add(curdate(),Interval -1 day) group by hour,filename order by hour">>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file

	echo "*********************** TBL_SUCCESSLOGS(COUNT)   **********************************">>$Sos_dir$log_file
	mysql -u$c -p$d MIS -e "select count(1) as SUCCESS_LOGS_COUNT from tbl_success_logs">>$Sos_dir$log_file
	
}


ussd_sos()
{
	septel="/opt/septel"
	if [ ! -d $Sos_dir ];then
		mkdir -p $Sos_dir
	fi
	mkdir "$Sos_dir"{ussd_pull,ussd_push}
	 echo "************************ ./gctloat -t1 **************************">>$Sos_dir$log_file
        $septel/gctload -t1>>$Sos_dir$log_file
        echo >>$Sos_dir$log_file
        echo >>$Sos_dir$log_file
        $septel/gctload -v>>$Sos_dir$log_file
        $septel/map_lnx6 -v>>$Sos_dir$log_file
        $septel/tcp_lnx6 -v>>$Sos_dir$log_file
        $septel/sccp_lnx6 -v>>$Sos_dir$log_file
        $septel/m3ua_lnx6 -v>>$Sos_dir$log_file
        echo "************************ ./gctloat -t2 **************************">>$Sos_dir$log_file
        $septel/gctload -t2>>$Sos_dir$log_file
        echo >>$Sos_dir$log_file
        echo >>$Sos_dir$log_file
        echo "*********************** SIU DETAILS*****************************************************">>$Sos_dir$log_file
        cat $septel/restart.sh |grep rsicmd|awk -F" " '{print $5, $6}'>>$Sos_dir$log_file
        if [ $? -eq 0 ];then
                SIU_IP=`cat $septel/restart.sh |grep rsicmd|awk -F" " '{print $5}'`
                ftp -vn <<config
                open $SIU_IP
                user $a $b
                get config.txt
                close
config
                mv config.txt $Sos_dir
                echo "*****************************CONFIG FILE COPIED FROM SIU **************************************">>$Sos_dir$log_file
        else
		cp -f $septel/config.txt $Sos_dir"septel"
        fi
        echo >>$Sos_dir$log_file
        echo >>$Sos_dir$log_file
	echo "********************** USSDPULL CONF FILE COPIED **********************************">>$Sos_dir$log_file	
        cp $septel/system.txt $Sos_dir"septel"
		cp -f $septel/config.txt $Sos_dir"septel"
	cp $septel/restart.sh $septel/*.ms7 $Sos_dir"septel"
	cp -f /home/ussd/*.sh $Sos_dir"ussd_pull"
	if [ -d /home/ussd/gateway/conf ];then
		cp -f /home/ussd/gateway/conf/*.* $Sos_dir"ussd_pull"
		cp -rf /home/ussd/gateway/menu_files $Sos_dir"ussd_pull"
		echo >>$Sos_dir$log_file
		echo >>$Sos_dir$log_file
	fi
	echo >>$Sos_dir$log_file
	echo >>$Sos_dir$log_file
	if [ -d /home/ussd/db_plugin/conf/ ];then
		cp /home/ussd/db_plugin/conf/* $Sos_dir"ussd_pull"
	fi
	if [ -d /home/ussd/smpp_plugin/conf/ ];then
                cp /home/ussd/smpp_plugin/conf/* $Sos_dir"ussd_pull"
        fi
	if [ -d /home/ussd/xml_plugin/conf/ ];then
                cp /home/ussd/xml_plugin/conf/* $Sos_dir"ussd_pull"
        fi

	if [ -d /home/ussd/push/push_gw/conf ];then
                cp /home/ussd/push/push_gw/conf/* $Sos_dir"ussd_push"
       	echo "********************** USSDPUSH CONF FILES COPIED **********************************">>$Sos_dir$log_file
        fi
}
#MYSQL=`chkconfig --list|grep mysql|awk '{print $1}'`
if [ ! -d $Sos_dir ];then
mkdir -p $Sos_dir
fi
mkdir "$Sos_dir"{septel,scripts,logs}
echo "Welcome to system stats capture script"
echo >>$Sos_dir$log_file
echo "************************ IPADDRESS INFORMATION *************************************">>$Sos_dir$log_file
ifconfig>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ KERNEL INFORMATION *************************************">>$Sos_dir$log_file
echo `uname -a`>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "*********************** SYSCTL OUTPUT **********************************">>$Sos_dir$log_file
sysctl -p>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ CPU INFORMATION    *************************************">>$Sos_dir$log_file
cat /proc/cpuinfo>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "********************** PROCESSES EATING CPU **********************************************" > temp3.txt
ps aux | awk '{print $2, $3, $11}' | sort -k2rn | head -n 10 >>$txt_file
ps aux | awk '{print $2, $4, $11}' | sort -k2rn | head -n 10 >>$txt_file1
while read line
do
        mem=$(echo $line|cut -d ' ' -f2)
        st=$(echo "$mem > 10.0"|bc)
        if [ $st -eq 1 ]
        then
                echo "$line" >> temp3.txt
        fi
done<$txt_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "********************** PROCESSES EATING MEMORY ********************************************" >> temp3.txt
while read line1
do
        mem1=$(echo $line1|cut -d ' ' -f2)
        st1=$(echo "$mem1 > 10.0"|bc)
        if [ $st1 -eq 1 ]
        then
                echo "$line1" >> temp3.txt
        fi
done<$txt_file1
cat temp3.txt >>$Sos_dir$log_file
cat temp3.txt|cut -d ' ' -f1|grep [0-9]|sort |uniq >$PID
rm -f temp3.txt $txt_file $txt_file1
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ AMOUNT OF FREE AND USED MEMORY(MB) *************************">>$Sos_dir$log_file
free -m>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ RUNNING PROCESSES ON SERVER ****************************">>$Sos_dir$log_file
ps -ax>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ ALL OPEN PORTS ON SERVER    ****************************">>$Sos_dir$log_file
nmap $hostIp>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ MYSQL CONNECTIONS ON SERVER **************************">>$Sos_dir$log_file
netstat -na|grep 3306>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ DISK SPACE ON SERVER **************************">>$Sos_dir$log_file
df -h>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ LOGS - /var/log/messages FILE COPIED **************************">>$Sos_dir$log_file
echo `tail -n1000 /var/log/messages > $Sos_dir"logs"message`
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ LOGS - /var/log/cron COPIED **************************">>$Sos_dir$log_file
echo `tail -n1000 /var/log/cron > $Sos_dir"logs"cron`
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ LOGS - /var/log/mysqld.log COPIED **************************">>$Sos_dir$log_file
echo `tail -n1000 /var/log/mysql.d > $Sos_dir"logs"mysql.log`
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ APACHE STATUS **************************">>$Sos_dir$log_file
ps -ef|grep java>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ CATALINA OUTPUT **************************">>$Sos_dir$log_file
Apache_path=` ps -ef|grep catalina|awk -Fbase= '{print $2}'|awk  '{print $1}'`
tail -n100 $Apache_path/logs/catalina.out>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "************************ PMAP FOR PROCESSES **************************">>$Sos_dir$log_file
cat $PID | while read binary
do

        pmap -x $binary>>$Sos_dir$log_file
	echo "PMAP output for $binary has Finished">>$Sos_dir$log_file
done
rm -f $PID
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo "*********************** SERVICES ON SERVER **********************************">>$Sos_dir$log_file
chkconfig --list>>$Sos_dir$log_file
echo >>$Sos_dir$log_file
echo >>$Sos_dir$log_file

### Calling  funcation

if [[ "$check_parameter_input" = "ussd" ]]
        then
        ussd_sos

fi

if [[ "$check_parameter_input" = "smsc" ]]
        then
        smsc_sos

fi

if [[ "$check_parameter_input" = "common" ]]
        then
        ussd_sos
	smsc_sos
fi

cd $pwd
tar -zcvf /tmp/"${Date}"_"${check_parameter_input}"_SOS-REPORT_"${hostIp}".tgz $Sos_dir
if [ $? -eq 0 ];then
	rm -rf $Sos_dir
fi
echo "Directory[ $Sos_dir ] has been successfully zipped";
