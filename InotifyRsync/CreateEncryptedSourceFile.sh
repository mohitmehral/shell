#!/bin/bash
pushd `dirname $0` > /dev/null
BASE_PATH=`pwd`
popd > /dev/null

echo -n "Enter IP:"
read IP

echo -n "Enter USERNAME:"
read USERNAME

echo -n "PASSWORD:"
read PASSWORD

echo -n "SOURCE_PATH:"
read -e SOURCEPATH

echo -n "DEST_PATH:"
read -e DESTPATH


echo -n "PORT:"
read USERPORT


#PASSWORDS_PATHS="$IP.pass"
PASSWORDS_PATHS="$BASE_PATH/$IP.pass"

echo "$PASSWORDS_PATHS"


	echo -n "$USERNAME $PASSWORD $SOURCEPATH $DESTPATH $USERPORT" | openssl enc -e -nosalt -out "$PASSWORDS_PATHS" -aes-256-cbc -pass pass:mySecretPass




#openssl enc -d -nosalt -in test.txt -out pass.txt -aes-256-cbc -pass pass:mySecretPass



	#echo "new line at $NEW_LINE"

	TEMP=`cat $PASSWORDS_PATHS |   openssl enc -d -nosalt  -aes-256-cbc -pass pass:mySecretPass`

	USER=`echo "$TEMP" | cut -d  ' ' -f1`
	PASS=`echo "$TEMP" | cut -d  ' ' -f2` 	
	SOURCEPATH=`echo "$TEMP" | cut -d  ' ' -f3`
	DESTPATH=`echo "$TEMP" | cut -d  ' ' -f4`
	PORT=`echo "$TEMP" | /bin/cut -d  ' ' -f5`

	echo "UserName is $USER"

	echo "Password is $PASS"

	echo "SOURCE PATH is $SOURCEPATH"

	echo "DEST PATH is $DESTPATH"

	echo "PORT is $PORT"

	echo "Password file genereated successfully."


#cat test.txt
