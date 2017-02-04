##############################################
#main script
#run Rsync.sh with pass file
###############################################

#!/bin/bash
pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

if [ -z "$1" ];then
	echo "please enter comment line param with this scrip"
	echo "#sh Rsync.sh <pass file>"
	echo "#e.g sh Rsync.sh 10.247.74.42.pass"
exit
fi

CUREENT_DATE=`date +%d-%m-%Y`
IP=`/sbin/ifconfig | head -n 2 | tail -n 1 | awk '{print $2}' | cut -c 6-`
LOG_PATH="/home/Logs/"`basename $0 .sh`"/$CUREENT_DATE"
FINAL_LOG_FILE_PATH="$LOG_PATH/FinalLogs-$CUREENT_DATE.log"
RSYNC_LOG_FILE_PATH="$LOG_PATH/RsyncLogs-$CUREENT_DATE.log"
DB_LOG_FILE_PATH="$LOG_PATH/MailLogs-$CUREENT_DATE.log"
#calling header file funcations

echo "$HOST_IP"
echo "port is $PORT"
cd $BASE_PATH

if [ ! -d "$LOG_PATH" ];then

        mkdir -p $LOG_PATH
        echo "LOGS DIRECTORY MADE"

fi




echo "#`date`#" >> $FINAL_LOG_FILE_PATH

if [ -f RsyncLogs.lck ];then

        echo "ALREADY INSTANCE RUNNING `date`" >> $FINAL_LOG_FILE_PATH
        echo "EXITING" >> $FINAL_LOG_FILE_PATH

else
       touch RsyncLogs.lck
        echo "NO INSTANCE RUNNING" >> $FINAL_LOG_FILE_PATH
 	
        PASS_FILE="$BASE_PATH/$1"
	DEST_IP="`basename $1 .pass`"
        TEMP=`cat $PASS_FILE  | openssl enc -d -nosalt  -aes-256-cbc -pass pass:mySecretPass`

        USERNAME=`echo "$TEMP" | cut -d  ' ' -f1`
        PASSWORD=`echo "$TEMP" | cut -d  ' ' -f2`
        SOURCE_PATH=`echo "$TEMP" | cut -d  ' ' -f3`
	DEST_PATH=`echo "$TEMP" | cut -d  ' ' -f4`
        PORT=`echo "$TEMP" | /bin/cut -d  ' ' -f5`
        echo "#`date`#" >> $RSYNC_LOG_FILE_PATH

        echo "CONNECTING RSYNC:" >> $FINAL_LOG_FILE_PATH
        echo "SOURCE PATH:$DEST_IP:$SOURCE_PATH" >> $FINAL_LOG_FILE_PATH
        echo "DEST PATH:$DEST_PATH" >> $FINAL_LOG_FILE_PATH

        echo "CALLING RsyncExpect.sh "$USERNAME" "$DEST_IP" "$DEST_PATH" "$PASSWORD" "$SOURCE_PATH" "$PORT"" >> $RSYNC_LOG_FILE_PATH
LIST_ARR=$(echo ${SOURCE_PATH} | tr "," "\n")
for i in $LIST_ARR
do
SOURCE_PATH=`echo "$i" | cut -d ':' -f1`
echo $SOURCE_PATH > test.log
#EMAIL=`echo "$i" | cut -d ':' -f2`
./RsyncExpect.sh "$USERNAME" "$DEST_IP" "$DEST_PATH" "$PASSWORD" "$SOURCE_PATH" "$PORT" 2>&1 1> logs.txt
 RSYNC_STATUS=`cat logs.txt | grep "sending incremental ..." | wc -l`

        if [ $RSYNC_STATUS -eq 1 ];then

                echo "RSYNC STATUS:SUCCESS" >> $FINAL_LOG_FILE_PATH

                TOTAL_FILES=`cat logs.txt | grep -E "\.conf|\.in" | wc -l`
                echo "TOTAL FILES COPIED:$TOTAL_FILES" >> $FINAL_LOG_FILE_PATH
                if [ $TOTAL_FILES -gt 0 ];then

                        cat logs.txt | grep "txt" > TempFiles.txt
                        dos2unix TempFiles.txt
                        echo "FILE NAMES GIVEN BELOW:" >> $FINAL_LOG_FILE_PATH
                        cat TempFiles.txt >> $FINAL_LOG_FILE_PATH

                        echo "0" > COUNT.NULL

                else
 COUNT=`cat COUNT.NULL`
                        COUNT=`expr $COUNT + 1`
                        echo "$COUNT" > COUNT.NULL
                        echo "NO FILES COPIED COUNT IS `cat COUNT.NULL`" >> $FINAL_LOG_FILE_PATH

                fi

        else

                echo "RSYNC STATUS:FAIL" >> $FINAL_LOG_FILE_PATH
##elinks --dump "http://192.168.9.34:8085/BulkMessaging/sendingSMS?ani=917696369630&uname=Mcommerce&passwd=341682&cli=SMSSDL&message=MCOM:48.21%20rsync with 48.22 fail SDL;"
        fi

        dos2unix logs.txt
        cat logs.txt >> $RSYNC_LOG_FILE_PATH




        echo -e "END\n" >> $FINAL_LOG_FILE_PATH
        echo -e "END\n" >> $RSYNC_LOG_FILE_PATH
rm -f RsyncLogs.lck



done
fi

