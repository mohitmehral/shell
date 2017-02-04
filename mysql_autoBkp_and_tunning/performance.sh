#!/bin/sh
#=== performance.sh ===
#Contributors: (mohitmehral@gmail.com )
#Tags: linux, mysql db
#Requires at least: no specific rpm required
#Stable tag: 2.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#== Description ==
# db-tunning-backup.sh: This script for tunning and backup DB sechma and table structures . Script read DB creditial 
#		from db.cfg file. List of backup sechma / table & tunned DB are placed in configuration file. Log / sechma /
#               other directory are also configurable. This script basically run once in day[EOD]
#===Revision History
# this shell script finds all the tables for a database and run a command against it
# @usage "mysql_tables.sh --optimize MyDatabaseABC"
#!/bin/bash

BASE_PATH=/home/ussd/scripts/db_management
cd $BASE_PATH
CONFIG_FILE="db.cfg"

# START - Read Config Params
while read param; do
CONFIG_PARAM=`echo "$param" | awk -F "=" '{print $1}'`

if [ "$CONFIG_PARAM" == "DB_USERNAME" ]; then
DB_USERNAME=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DB_PASSWD" ]; then
DB_PASSWD=`echo "$param" | awk -F "=" '{print $2}'`
fi
done < $CONFIG_FILE
# END - Read Config Params


DBNAME=$2

printUsage() {
  echo "Usage: $0"
  echo " --optimize <dbname>"
  echo " --repair <dbname>"
  return
}


doAllTables() {
  # get the table names
  TABLENAMES=`mysql -u ${DB_USERNAME} -p${DB_PASSWD} -D $DBNAME -e "SHOW TABLES\G;"|grep 'Tables_in_'|sed -n 's/.*Tables_in_.*: \([_0-9A-Za-z]*\).*/\1/p'`

  # loop through the tables and optimize them
  for TABLENAME in $TABLENAMES
  do
    mysql -u ${DB_USERNAME} -p${DB_PASSWD} -D $DBNAME -e "$DBCMD TABLE $TABLENAME;"
  done
}

if [ $# -eq 0 ] ; then
  printUsage
  exit 1
fi

case $1 in
  --optimize) DBCMD=OPTIMIZE; doAllTables;;
  --repair) DBCMD=REPAIR; doAllTables;;
  --help) printUsage; exit 1;;
  *) printUsage; exit 1;;
esac

