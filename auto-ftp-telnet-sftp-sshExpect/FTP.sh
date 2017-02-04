*******************************************************************
. ~/.bash_profile
################## VARIABLES ###########################
#Configure as per requirement

SOURCE_PATH="/tmp/"
LOG_PATH="/tmp/FTP_FILES/"
WINDOWS_SERVER=10.1.1.1
PORT=
LOCALDIR=
FILENAME=$DATE.tgz
username=
user=
password=

###########################################
#FIXED Variable
FOLDER_NAME=`date -d "1 day ago" +%Y-%m-%d`
DATE=`date -d "1 day ago" +%Y%m%d`
log_file=`date +%Y%m%d_ftplogs.txt`
log_file_path1="/tmp/logs/$log_file"
FILE_EURO=*${DATE}*.txt
WINDOWS_SERVER=10.1.1.1
PORT=
LOCALDIR=
FILENAME=$DATE.tgz
username=
user=
password=
########################################################

########################################################
mkdir -p ${LOG_PATH}/$FOLDER_NAME

cp -f ${SOURCE_PATH}/$FILE_EURO $LOG_PATH/${FOLDER_NAME}

cd ${LOG_PATH}/
tar -cvzf ${FOLDER_NAME}.tgz ${FOLDER_NAME}
if [ $? -ne 0 ];then
        echo " Unable to TAR log file [${LOG_PATH}/${FOLDER_NAME}]" >>$log_file_path1
               exit
else
        echo "TAR FILE CREATED SUCCESSFULLY " >>$log_file_path1
fi
cd -

####### Now going to FTP files ##############
cd ${LOG_PATH}
ftp -in << EOF
open $WINDOWS_SERVER
$user $username $password
ascii
lcd $LOCALDIR
put $FILENAME
close
 echo "file transfer successfuly" >>$log_file_path1
EOF
cd -

*********************************************************

