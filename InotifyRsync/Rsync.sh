#!/bin/bash
pushd `dirname $0` > /dev/null 
BASE_PATH=`pwd`
popd > /dev/null

echo $BASE_PATH
CUREENT_DATE=`date +%d-%m-%Y`
IP=`/sbin/ifconfig | head -n 2 | tail -n 1 | awk '{print $2}' | cut -c 6-`
LOG_PATH="/home/Logs/"`basename $0 .sh`"/$CUREENT_DATE"
FINAL_LOG_FILE_PATH="$LOG_PATH/FinalLogs-$CUREENT_DATE.log"
RSYNC_LOG_FILE_PATH="$LOG_PATH/RsyncLogs-$CUREENT_DATE.log"
DB_LOG_FILE_PATH="$LOG_PATH/MailLogs-$CUREENT_DATE.log"
DEST_IP="$1"
TEMPFILE=$BASE_PATH/tmpfiles/$1
cd $BASE_PATH
#. $BASE_PATH/read_config.h
#calling header file funcations
#$READ_CONFIG

echo "$HOST_IP"
echo "port is $PORT"
cd $BASE_PATH
if [ ! -d "$TEMPFILE" ];then

        mkdir -p $TEMPFILE
        echo "LOGS DIRECTORY TEMP FILE CREATED"

fi
if [ ! -d "$LOG_PATH" ];then

        mkdir -p $LOG_PATH
        echo "LOGS DIRECTORY MADE"

fi




echo "#`date`#" >> $FINAL_LOG_FILE_PATH

if [ -f $TEMPFILE/$DEST_IP.lck ];then

        echo "ALREADY INSTANCE RUNNING `date`" >> $FINAL_LOG_FILE_PATH
        echo "EXITING" >> $FINAL_LOG_FILE_PATH

else
       touch $TEMPFILE/$DEST_IP.lck
        echo "NO INSTANCE RUNNING" >> $FINAL_LOG_FILE_PATH
 	
        USERNAME=$2
        PASSWORD=$3
        SOURCE_PATH=$4
	DEST_PATH=$5
        PORT=$6
        echo "#`date`#" >> $RSYNC_LOG_FILE_PATH

        echo "CONNECTING RSYNC:" >> $FINAL_LOG_FILE_PATH
        echo "SOURCE PATH:$DEST_IP:$SOURCE_PATH" >> $FINAL_LOG_FILE_PATH
        echo "DEST PATH:$DEST_PATH" >> $FINAL_LOG_FILE_PATH

        echo "CALLING RsyncExpect.sh "$USERNAME" "$DEST_IP" "$DEST_PATH" "$PASSWORD" "$SOURCE_PATH" "$PORT"" >> $RSYNC_LOG_FILE_PATH
LIST_ARR=$(echo ${SOURCE_PATH} | tr "," "\n")
for i in $LIST_ARR
do
SOURCE_PATH=`echo "$i" | cut -d ':' -f1`
echo $SOURCE_PATH > $TEMPFILE/test.log
#EMAIL=`echo "$i" | cut -d ':' -f2`
./RsyncExpect.sh "$USERNAME" "$DEST_IP" "$DEST_PATH" "$PASSWORD" "$SOURCE_PATH" "$PORT" 2>&1 1> $TEMPFILE/logs.txt
 RSYNC_STATUS=`cat $TEMPFILE/logs.txt | grep "sending incremental ..." | wc -l`

        if [ $RSYNC_STATUS -eq 1 ];then

                echo "RSYNC STATUS:SUCCESS" >> $FINAL_LOG_FILE_PATH
		COUNT_FILE=COUNT.$DEST_IP

                TOTAL_FILES=`cat $TEMPFILE/logs.txt | grep -E "\.conf|\.in" | wc -l`
                echo "TOTAL FILES COPIED:$TOTAL_FILES" >> $FINAL_LOG_FILE_PATH
                if [ $TOTAL_FILES -gt 0 ];then

                        cat $TEMPFILE/logs.txt | grep -E "\.conf|\.in" > $TEMPFILE/TempFiles.txt
                        dos2unix $TEMPFILE/TempFiles.txt
                        echo "FILE NAMES GIVEN BELOW:" >> $FINAL_LOG_FILE_PATH
                        cat $TEMPFILE/TempFiles.txt >> $FINAL_LOG_FILE_PATH


			#COUNT_FILE=COUNT.$DEST_IP
                        echo "0" > $TEMPFILE/$COUNT_FILE

                else

			if [ ! -f "$TEMPFILE/$COUNT_FILE" ];then

			       echo "0" > $TEMPFILE/$COUNT_FILE

			fi



 			COUNT=`cat $TEMPFILE/$COUNT_FILE`
                        COUNT=`expr $COUNT + 1`
                        echo "$COUNT" > $TEMPFILE/$COUNT_FILE
                        echo "NO FILES COPIED COUNT IS `cat $TEMPFILE/$COUNT_FILE`" >> $FINAL_LOG_FILE_PATH

                fi

        else

                echo "RSYNC STATUS:FAIL" >> $FINAL_LOG_FILE_PATH
##elinks --dump "http://192.168.9.34:8085/BulkMessaging/sendingSMS?ani=917696369630&uname=Mcommerce&passwd=341682&cli=SMSSDL&message=MCOM:48.21%20rsync with 48.22 fail SDL;"
        fi

        dos2unix $TEMPFILE/logs.txt
        cat $TEMPFILE/logs.txt >> $RSYNC_LOG_FILE_PATH




        echo -e "END\n" >> $FINAL_LOG_FILE_PATH
        echo -e "END\n" >> $RSYNC_LOG_FILE_PATH
rm -f $TEMPFILE/$DEST_IP.lck



done
fi

