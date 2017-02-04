#!/bin/bash
####################################################################################################
#
# compress_move_gw_logs.sh :: This script move logs from given path to other partition where space available.
#			This script facilitate bundle/zip the logs in monthly bases
#                       This script basically run once in EOD
# Revision History
#
# Date        Name              Reason
# ----        ----              ------
# 01-03-2012  Mohit Mehral     Configurable all parameters.
###################################################################################################

#Initilization of variables
BASE_PATH=/home/ussd/scripts/log_management
CONFIG_FILE="compress_move_gw_logs.cfg"

if [ ! -d $BASE_PATH ];then
	echo " Base Directory not exists![$BASE_PATH]"
	exit
fi
cd $BASE_PATH

#Header files
. $BASE_PATH/read_config.h
#calling header file funcations
READ_CONFIG
DATE_TIME
##LOG Directory
if [ ! -d $SCRIPT_LOGS ];then
                echo " Log Directory note found [$SCRIPT_LOGS]"
                mkdir -p $SCRIPT_LOGS
        fi

log_file_path="$SCRIPT_LOGS/${CUREENT_DATE}-"`basename $0 .sh`".log"
echo "############ Script:$log_file_path##################" >$log_file_path
#####Funcations
PUSH_LOG() 
{
#Executation Conditions
	if [ ! -d $SOURCE_PATH_PUSH_LOGS ];then
        	echo " Log Directory note found [$SOURCE_PATH_PUSH_LOGS]" >>$log_file_path
	        exit
	fi
	if [ ! -d $DESTINATION_PATH_PUSH_LOGS ];then
        	echo " Log Directory note found [$DESTINATION_PATH_PUSH_LOGS]" >>$log_file_path
	        mkdir -p $DESTINATION_PATH_PUSH_LOGS
	fi
#create monthly backup directory if not extist in new system
	cd $DESTINATION_PATH_PUSH_LOGS
	if [ ! -d $CURRENT_MONTH ];then
        	echo " Log Directory note found [$CURRENT_MONTH]"
        	mkdir -p $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH
		if [ $? -ne 0 ];then
        		echo "Unable to create Directory[$DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH]" >>$log_file_path
			exit
		fi
		else
			continue;
 

	fi
	if [ ! -d $LAST_MONTH ];then
                echo " Log Directory note found [$LAST_MONTH]"
                mkdir -p $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH
                if [ $? -ne 0 ];then
                        echo "Unable to create Directory[$DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH]" >>$log_file_path
                        exit
                fi
                else
                        continue;

        fi


	echo "USSD PUSH Log Files moving started from path[$SOURCE_PATH_PUSH_LOGS] to path[$DESTINATION_PATH_PUSH_LOGS] at `date`" >> $log_file_path

	TEMP_MOVE_LAST_NO_OF_DAYS_PUSH_LOGS=$(expr $MOVE_LAST_NO_OF_DAYS_PUSH_LOGS + 1)
	TEMP_DATE=`date -d "$TEMP_MOVE_LAST_NO_OF_DAYS_PUSH_LOGS day ago" "+%d"`

	if [ $CURRENT_DAY -le $TEMP_DATE ];then
		#find /tmp/ -type f -mtime 2 -exec mv {} /tmp/script_logs \;
		#echo "$LAST_MONTH"
		if [  ! -d $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE ];then
			mkdir $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE
		else
			continue;
		fi
		
		find $SOURCE_PATH_PUSH_LOGS -type f -mtime $MOVE_LAST_NO_OF_DAYS_PUSH_LOGS -exec mv {} $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE \; 
		cd $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH
		tar -czf ${TEMP_DATE}_auto.tgz $TEMP_DATE  
		if [ $? -eq 0 ];then
                        if [ -d $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE ];then
                                cd $DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH 
                                rm -f $TEMP_DATE/*;rm -f $TEMP_DATE/*.*;
			else
				echo " Unable to delete the directory [$DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
				continue;
                        fi
		else
			echo " Unable to delete the directory [$DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
			continue;
                fi
	
		
	else
		#echo "$CURRENT_MONTH"
		if [  ! -d $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH/$TEMP_DATE ];then
			mkdir $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH/$TEMP_DATE
		else
                        continue;
		fi
		find $SOURCE_PATH_PUSH_LOGS -type f -mtime $MOVE_LAST_NO_OF_DAYS_PUSH_LOGS -exec mv {} $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH/$TEMP_DATE \; 
		cd $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH
		tar -czf ${TEMP_DATE}_auto.tgz $TEMP_DATE
		if [ $? -eq 0 ];then
			if [ -d $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH/$TEMP_DATE ];then
                                cd $DESTINATION_PATH_PUSH_LOGS/$CURRENT_MONTH
                                rm -f $TEMP_DATE/*;rm -f $TEMP_DATE/*.*;
			else
				echo " Unable to delete the directory [$DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
				continue;
			fi
			
		else
			continue;
			echo " Unable to delete the directory [$DESTINATION_PATH_PUSH_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
                fi
	fi
	echo "USSD PUSH Log Files moving END from path[$SOURCE_PATH_PUSH_LOGS] to path[$DESTINATION_PATH_PUSH_LOGS] at `date`" >> $log_file_path
}
#PUSH_LOG() CLOSE

PULL_LOG()
{
#Executation Conditions
        if [ ! -d $SOURCE_PATH_PULL_LOGS ];then
                echo " Log Directory note found [$SOURCE_PATH_PULL_LOGS]" >>$log_file_path
                exit
        fi
        if [ ! -d $DESTINATION_PATH_PULL_LOGS ];then
                echo " Log Directory note found [$DESTINATION_PATH_PULL_LOGS]" >>$log_file_path
                mkdir -p $DESTINATION_PATH_PULL_LOGS
        fi
#create monthly backup directory if not extist in new system
        cd $DESTINATION_PATH_PULL_LOGS
        if [ ! -d $CURRENT_MONTH ];then
                echo " Log Directory note found [$CURRENT_MONTH]"
                mkdir -p $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH
                if [ $? -ne 0 ];then
                        echo "Unable to create Directory[$DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH]" >>$log_file_path
                        exit
                fi
                else
                        continue;

        fi
        if [ ! -d $LAST_MONTH ];then
                echo " Log Directory note found [$LAST_MONTH]"
                mkdir -p $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH
                if [ $? -ne 0 ];then
                        echo "Unable to create Directory[$DESTINATION_PATH_PULL_LOGS/$LAST_MONTH]" >>$log_file_path
 			exit
                fi
                else
                        continue;

        fi


        echo "USSD PULL Log Files moving started from path[$SOURCE_PATH_PULL_LOGS] to path[$DESTINATION_PATH_PULL_LOGS] at `date`" >> $log_file_path

        TEMP_MOVE_LAST_NO_OF_DAYS_PULL_LOGS=$(expr $MOVE_LAST_NO_OF_DAYS_PULL_LOGS + 1)
        TEMP_DATE=`date -d "$TEMP_MOVE_LAST_NO_OF_DAYS_PULL_LOGS day ago" "+%d"`

        if [ $CURRENT_DAY -le $TEMP_DATE ];then
                #find /tmp/ -type f -mtime 2 -exec mv {} /tmp/script_logs \;
                #echo "$LAST_MONTH"
                if [  ! -d $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE ];then
                        mkdir $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE
                else
                        continue;
                fi

                find $SOURCE_PATH_PULL_LOGS -type f -mtime $MOVE_LAST_NO_OF_DAYS_PULL_LOGS -exec mv {} $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE \;
                cd $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH
                tar -czf ${TEMP_DATE}_auto.tgz $TEMP_DATE
                if [ $? -eq 0 ];then
                        if [ -d $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE ];then
                                cd $DESTINATION_PATH_PULL_LOGS/$LAST_MONTH
                                rm -f $TEMP_DATE/*;rm -f $TEMP_DATE/*.*;
                        else
                                echo " Unable to delete the directory [$DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
                                continue;
 fi
                else
                        echo " Unable to delete the directory [$DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
                        continue;
                fi


        else
                #echo "$CURRENT_MONTH"
                if [  ! -d $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH/$TEMP_DATE ];then
                        mkdir $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH/$TEMP_DATE
                else
                        continue;
                fi
                find $SOURCE_PATH_PULL_LOGS -type f -mtime $MOVE_LAST_NO_OF_DAYS_PULL_LOGS -exec mv {} $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH/$TEMP_DATE \;
                cd $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH
                tar -czf ${TEMP_DATE}_auto.tgz $TEMP_DATE
                if [ $? -eq 0 ];then
                        if [ -d $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH/$TEMP_DATE ];then
                                cd $DESTINATION_PATH_PULL_LOGS/$CURRENT_MONTH
                                rm -f $TEMP_DATE/*;rm -f $TEMP_DATE/*.*;
                        else
                                echo " Unable to delete the directory [$DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
                                continue;
                        fi

                else
                        continue;
                        echo " Unable to delete the directory [$DESTINATION_PATH_PULL_LOGS/$LAST_MONTH/$TEMP_DATE]" >> $log_file_path
                fi
        fi
        echo "USSD PULL Log Files moving END from path[$SOURCE_PATH_PULL_LOGS] to path[$DESTINATION_PATH_PULL_LOGS] at `date`" >> $log_file_path
} #PULL_LOG() CLOSE
SCRIPT_LOG()
{
	if [ -d $SCRIPT_LOGS ];then
		find $SCRIPT_LOGS -type f -mtime -$NO_OF_DAYS_KEEP_SCRIPT_LOGS -exec rm {} \;
		
        fi
} #SCRIPT_LOG() CLOSE

# Funcation calling
PUSH_LOG
PULL_LOG
SCRIPT_LOG
