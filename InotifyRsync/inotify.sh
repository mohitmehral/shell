##############################################
#main script
#run inotify.sh with pass file
###############################################
if [ -z "$1" ];then
echo "please enter comment line param with this scrip"
echo "#sh inotify.sh <pass file>"
echo "#e.g sh inotify.sh 10.247.74.42.pass"
exit
fi

pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

PASS_FILE="$1"
DEST_IP="`basename $1 .pass`"
        TEMP=`cat $PASS_FILE  | openssl enc -d -nosalt  -aes-256-cbc -pass pass:mySecretPass`
        USERNAME=`echo "$TEMP" | cut -d  ' ' -f1`
        PASSWORD=`echo "$TEMP" | cut -d  ' ' -f2`
        SOURCE_PATH=`echo "$TEMP" | cut -d  ' ' -f3`
        DEST_PATH=`echo "$TEMP" | cut -d  ' ' -f4`
        PORT=`echo "$TEMP" | /bin/cut -d  ' ' -f5`

while true #run indefinitely
do
inotifywait -e close_write $SOURCE_PATH && /bin/bash $BASE_PATH/Rsync.sh $DEST_IP $USERNAME $PASSWORD $SOURCE_PATH $DEST_PATH $PORT
done
