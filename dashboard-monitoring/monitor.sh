##################################################
#=== Plugin Name ===
#Contributors: (mohitmehral@gmail.com )
#Tags: monitoring process and rpc queue.
#Requires at least: no specific rpm required
#Stable tag: 2.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#== Description ==
#his script use to montior the linux machine and application binaries
#ps
#ipcs

#== how to run the script
#Step 1: create file binary_list.txt - in this list add binaries / application which want to be monitor on dashboard
#Step 2: creare file queue.txt -  add list of ipcs queue ID which want to monitor on dashboard.
#step 3. run monitor.sh
##################################################
#!/bin/bash

pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

log_file=`basename $1.log`
log_file_path="$BASE_PATH/$logfile"
DATE=`date +%Y-%m-%d" "%H:%M`
file_name="/$BASE_PATH/binary_list.txt"
queuefile="/$BASE_PATH/queues.txt"

#echo "*********CPU Performance Report*******************"
#mpstat| grep all |  awk '{print " CPU Util : " 100 - $10 "%"}'
#free | grep Mem: | awk '{print  " Mem Util : " $3/$2*100 "%"}'
curr_time=`date +%H |awk '{print $1}'`
ps -C gctload &> /dev/null

# If gctload is not running do following
if [ $? -ne 0 ]
then

        mesg="$HOST_NAME: gctload not running. Singnalling Down `date`"
        echo "$HOST_NAME: gctload not running. Singnalling Down`date`" >> $log_file_path
fi
echo "************ Message Queue***********************************"
cat  $queuefile | while read binary
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

                #check if the queue exists or not
                hexvalue="`echo $binary  | cut -d: -f1`"
                qname="`echo $binary | cut -d: -f2`"
                qcount=`ipcs -q | grep "$hexvalue" | wc -l`
                if [ "$qcount" -eq 0 ]
                 then
                #       echo "Queue not created "
                        mesg="$HOST_NAME Q$name not created pls chk`date`"
                #       mysql -h$HOST -u$MIS_USER -p$MIS_PASS $MIS_DB -e "call proc_Alerts('$mesg','Q','$CLI')" > /dev/null &
                        echo $msg >> $log_file_path
                else
                       # echo "Queue present, now checking pendency"
                        qpendency=`ipcs -q | grep "$hexvalue" | awk '{ print $6}'`

                        echo "$HOST_NAME: Message $qname pendency: $qpendency"
                        if [ "$qpendency" -gt 200 ]
                        then
                                mesg="$HOST_NAME: $qname q pendency=$qpendency Please chk !!!`date`"
                                mysql -h$HOST -u$MIS_USER -p$MIS_PASS $MIS_DB -e "call proc_Alerts('$mesg','G','$CLI')"
                                echo $mesg >> $log_file_path
                        fi


                fi
fi
done
echo "************Success & Failure count **************************"

cd /home/ussd/gateway/log

if [ -e `date +%G%m%d%H`-ussd-success.txt ]
        then
        echo Total Success this hour :::
        cat  `date +%G%m%d%H`-ussd-success.txt | wc -l
        else
        echo NO `date +%G%m%d%H`-ussd-success.txt  file this hour !!!
fi

if [ -e `date +%G%m%d%H`-ussd-failure.txt ]
        then
        echo Total Failure this hour :::
        cat `date +%G%m%d%H`-ussd-failure.txt | wc -l
        else
        echo NO `date +%G%m%d%H`-ussd-failure.txt  this hour !!!
fi
cd -
sleep 5s
LOG_DIRECTORY=/home/ussd/gateway/log
SHORT_CODE_FILE="short_codes.txt"
DATE_S=`date -d "1 day ago" +%Y%m%d`
TEMP_FILE=`date +%Y%m%d`_temp.txt
>$TEMP_FILE
OUTPUT_FILE=output_${DATE_S}.csv
>$OUTPUT_FILE
START_TIME=$(date +%F\ %X)
echo "Processing logs of $DATE_S"  >>$OUTPUT_FILE
echo -------------------------------START_TIME = $START_TIME--------------------------------- >>$OUTPUT_FILE
yyyy=`echo $DATE_S | cut -c -4`
mm=`echo $DATE_S | cut -c 5-6`
dd=`echo $DATE_S | cut -c 7-8`
DATE_1=$yyyy/$mm/$dd

######## Print Headers (Shortcodes) #########
echo -n HOUR,FIELDS, >>$OUTPUT_FILE
cat $SHORT_CODE_FILE | while read short_code
do
        SHORT_CODE_TO_BE_SEARCHED=`echo $short_code | awk -F " " '{print $1}'`
        echo -n $SHORT_CODE_TO_BE_SEARCHED, >>$OUTPUT_FILE
done
        echo "" >>$OUTPUT_FILE

for hour in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
do
################ FIELD 1 (TOTAL REQUESTS) ########################
echo -n $hour,TOTAL, >>$OUTPUT_FILE
cat $SHORT_CODE_FILE | while read short_code
        do
                SHORT_CODE_TO_BE_SEARCHED=`echo $short_code | awk -F "*" '{print $2}'`
                if [[ $SHORT_CODE_TO_BE_SEARCHED == "Gateway" ]];then
                  SHORT_CODE_TO_BE_SEARCHED="*."
                fi
                FILENAME=${DATE_S}${hour}-ussd-success.txt
                FILENAME1=${DATE_S}${hour}-ussd-failure.txt
                TOTAL=`cat $LOG_DIRECTORY/$FILENAME $LOG_DIRECTORY/$FILENAME1 | grep ",.$SHORT_CODE_TO_BE_SEARCHED," | wc -l`
                echo -n $TOTAL, >>$OUTPUT_FILE
        done
        echo " " >>$OUTPUT_FILE
################ FIELD 2 (SUCCESS COUNT) ########################
        echo -n $hour,SUCCESS, >>$OUTPUT_FILE
        cat $SHORT_CODE_FILE | while read short_code
        do
                SHORT_CODE_TO_BE_SEARCHED=`echo $short_code | awk -F "*" '{print $2}'`
                if [[ $SHORT_CODE_TO_BE_SEARCHED == "Gateway" ]];then
                  SHORT_CODE_TO_BE_SEARCHED="*."
                fi
                FILENAME=${DATE_S}${hour}-ussd-success.txt
                SUCCESS_COUNT=`cat $LOG_DIRECTORY/$FILENAME | grep ",.$SHORT_CODE_TO_BE_SEARCHED," | wc -l`
                echo -n $SUCCESS_COUNT, >>$OUTPUT_FILE
        done
        echo " " >>$OUTPUT_FILE
################ FIELD 6 (TIMEOUT)  #################################
        echo -n $hour,TIMEOUT, >>$OUTPUT_FILE
        cat $SHORT_CODE_FILE | while read short_code
        do
                SHORT_CODE_TO_BE_SEARCHED=`echo $short_code | awk -F "*" '{print $2}'`
                if [[ $SHORT_CODE_TO_BE_SEARCHED == "Gateway" ]];then
                  SHORT_CODE_TO_BE_SEARCHED="*."
                fi
                FILENAME=${DATE_S}${hour}-ussd-failure.txt
                cat $LOG_DIRECTORY/$FILENAME | grep ",.$SHORT_CODE_TO_BE_SEARCHED," | awk -F "," '{print $11}' >$TEMP_FILE
                Network_Abort=`cat $TEMP_FILE | egrep -w "TIMEOUT" | wc -l`
                echo -n $Network_Abort, >>$OUTPUT_FILE
        done
        echo "" >>$OUTPUT_FILE

 echo -n $hour,U_ABORT, >>$OUTPUT_FILE
        cat $SHORT_CODE_FILE | while read short_code
        do
                SHORT_CODE_TO_BE_SEARCHED=`echo $short_code | awk -F "*" '{print $2}'`
                if [[ $SHORT_CODE_TO_BE_SEARCHED == "Gateway" ]];then
                  SHORT_CODE_TO_BE_SEARCHED="*."
                fi
                FILENAME=${DATE_S}${hour}-ussd-failure.txt
                cat $LOG_DIRECTORY/$FILENAME | grep ",.$SHORT_CODE_TO_BE_SEARCHED," | awk -F "," '{print $11}' >$TEMP_FILE
                Network_Abort=`cat $TEMP_FILE | egrep -w "U_ABORT" | wc -l`
                echo -n $Network_Abort, >>$OUTPUT_FILE
        done
        echo "" >>$OUTPUT_FILE


done

cat $file_name | while read binary
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
                ps -C $binary &> /dev/null
                if [ $? -ne 0 ]
                then
                        # Spawn the command in the background
                        mesg="$binary service not running on $HOST_NAME at `date`"
                        echo "$binary service not running on $HOST_NAME at `date`" >> $log_file_path
		else 
			echo "$binary running"
		fi 
	fi
done
rm $TEMP_FILE
