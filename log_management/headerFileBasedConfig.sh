# read_config.h :: Header file to which contain the funcation to read the cfg file.
#!/bin/bash
DATE_TIME()
{
        CUREENT_DATE=`date -d "0 day" "+%Y%m%d"`      #2012-06-22
        CURRENT_MONTH=`date -d "0 month" "+%B%Y"`      #June2012
        CURRENT_DAY=`date -d "0 day" "+%d"`          #01
        YESTERDAY=`date -d "1 day ago" "+%d"`     #30
        LAST_MONTH=`date -d "1 month ago" "+%B%Y"`  #May2012
        LAST_DATE=`date -d "1 day ago" "+%Y%m%d"`  #2012-06-21
	CURRENT DATA_TIME=`date +%Y-%m-%d" "%H:%M` #2012-03-14 10:51
}

#main.sh
#!/bin/bash

#Initilization of variables
BASE_PATH=`pwd`
#Header files
. $BASE_PATH/read_config.h
#calling header file funcations

DATE_TIME
##LOG Directory
if [ ! -d $SCRIPT_LOGS ];then
                echo " Log Directory note found [$SCRIPT_LOGS]"
                mkdir -p $SCRIPT_LOGS
        fi

LogFile="$SCRIPT_LOGS/${CUREENT_DATE}-"`basename $0 .sh`".log"
echo $LogFile
