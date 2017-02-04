#!/bin/bash
####################################################################################################
#
# read_config.h :: Header file to which contain the funcation to read the cfg file. 
#
# Revision History
#
# Date        Name              Reason
# ----        ----              ------
# 09-03-2016  Karan Chandok      Initial
###################################################################################################
pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

cd $BASE_PATH

READ_CONFIG()
{
        while read param; do
        CONFIG_PARAM=`echo "$param" | awk -F "=" '{print $1}'`
 	 
        #if [ $CONFIG_PARAM = \# ]; then
         #       continue
        #fi 

	
	if [ "$CONFIG_PARAM" == "USER" ]; then
                USER=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "PASSWORD" ]; then
                PASSWORD=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "HOST_IP" ]; then
                HOST_IP=`echo "$param" | awk -F "=" '{print $2}'`

        elif [ "$CONFIG_PARAM" == "PORT" ]; then
                PORT=`echo "$param" | awk -F "=" '{print $2}'`

	elif [ "$CONFIG_PARAM" == "SOURCE_PATH" ]; then
                SOURCE_PATH=`echo "$param" | awk -F "=" '{print $2}'`



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
        CURRENT_DATE_CG=`date "-d 0 day" "+%-d-%-m-%Y"` #13-7-2013
        CURRENT_DATE_CG1=`date "-d 0 day" "+%_d-%-m-%Y" | tr -d ' '` #3-7-2013
        CURR_DATE_TIME=`date +%d%b%Y-%H:%M:%S`

}

