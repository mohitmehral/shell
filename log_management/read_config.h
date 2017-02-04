#!/bin/bash
####################################################################################################
#
# read_config.h :: Header file to which contain the funcation to read the cfg file. 
#
# Revision History
#
# Date        Name              Reason
# ----        ----              ------
# 29-02-2012  Mohit Mehral      Initial
###################################################################################################

BASE_PATH=/home/ussd/scripts/log_management
cd $BASE_PATH

READ_CONFIG()
{
        while read param; do
        CONFIG_PARAM=`echo "$param" | awk -F "=" '{print $1}'`
 	 
        #if [ $CONFIG_PARAM = \# ]; then
         #       continue
        #fi 


        if [ "$CONFIG_PARAM" == "DB_HOST" ]; then
                DB_HOST=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "DB_PORT" ]; then
                DB_PORT=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "DB_USERNAME" ]; then
                DB_USERNAME=`echo "$param" | awk -F "=" '{print $2}'`
	
	elif [ "$CONFIG_PARAM" == "DB_PASSWD" ]; then
                DB_PASSWD=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "MIS_DB" ]; then
                MIS_DB=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "HOURLY_MIS_TABLE" ]; then
                HOURLY_MIS_TABLE=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "DAILY_MIS_TABLE" ]; then
                DAILY_MIS_TABLE=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "MONTHLY_MIS_TABLE" ]; then
                MONTHLY_MIS_TABLE=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "GW_LOG_DIR" ]; then
                GW_LOG_DIR=`echo "$param" | awk -F "=" '{print $2}'`
	
#<< move_zip_logs.sh#	
	elif [ "$CONFIG_PARAM" == "SOURCE_PATH_PUSH_LOGS" ]; then
                SOURCE_PATH_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`	
	elif [ "$CONFIG_PARAM" == "MOVE_LAST_NO_OF_DAYS_PUSH_LOGS" ]; then
                MOVE_LAST_NO_OF_DAYS_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
	elif [ "$CONFIG_PARAM" == "DESTINATION_PATH_PUSH_LOGS" ]; then
                DESTINATION_PATH_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
	
	elif [ "$CONFIG_PARAM" == "SOURCE_PATH_PULL_LOGS" ]; then
                SOURCE_PATH_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
        elif [ "$CONFIG_PARAM" == "MOVE_LAST_NO_OF_DAYS_PULL_LOGS" ]; then
                MOVE_LAST_NO_OF_DAYS_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
        elif [ "$CONFIG_PARAM" == "DESTINATION_PATH_PULL_LOGS" ]; then
                DESTINATION_PATH_PUSH_LOGS=`echo "$param" | awk -F "=" '{print $2}'`	

	elif [ "$CONFIG_PARAM" == "SCRIPT_LOGS" ]; then
                SCRIPT_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
	elif [ "$CONFIG_PARAM" == "NO_OF_DAYS_KEEP_SCRIPT_LOGS" ]; then
                NO_OF_DAYS_KEEP_SCRIPT_LOGS=`echo "$param" | awk -F "=" '{print $2}'`
####################
        fi
	
done < $CONFIG_FILE
}
# various Date format
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
