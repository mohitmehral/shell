#!/bin/bash
####################################################################################################
#=== db-tunning-backup.sh ===
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
#Revision History
#
# Date        Name              Reason
# ----        ----              ------
# 30-11-2009  Mohit Mehral      Initial
#
###################################################################################################

BASE_PATH=/home/ussd/scripts/db_management
cd $BASE_PATH
CONFIG_FILE="db.cfg"

# START - Read Config Params
while read param; do
CONFIG_PARAM=`echo "$param" | awk -F "=" '{print $1}'`

if [ "$CONFIG_PARAM" == "MASTER_DB" ]; then
MASTER_DB=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DB_HOST" ]; then
DB_HOST=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DB_PORT" ]; then
DB_PORT=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DB_USERNAME" ]; then
DB_USERNAME=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DB_PASSWD" ]; then
DB_PASSWD=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "MASTER_DB_TABLES" ]; then
MASTER_DB_TABLES=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "DATABASES" ]; then
DATABASES=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "schema_backup" ]; then
schema_backup=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "table_backup" ]; then
table_backup=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "script_logs" ]; then
logs=`echo "$param" | awk -F "=" '{print $2}'`

elif [ "$CONFIG_PARAM" == "no_of_days_keep_the_schema_backup" ]; then
no_of_days_keep_the_schema_backup=`echo "$param" | awk -F "=" '{print $2}'`
elif [ "$CONFIG_PARAM" == "no_of_days_keep_the_table_backup" ]; then
no_of_days_keep_the_table_backup=`echo "$param" | awk -F "=" '{print $2}'`
elif [ "$CONFIG_PARAM" == "no_of_days_keep_the_script_logs" ]; then
no_of_days_keep_the_script_logs=`echo "$param" | awk -F "=" '{print $2}'`

fi
done < $CONFIG_FILE
# END - Read Config Params

# Creating log/backup directories if not exisits #
if [ ! -d $schema_backup ];then
        mkdir -p $schema_backup
	echo "New Directory created [ $schema_backup ]"
fi

if [ ! -d $table_backup ];then
        mkdir -p $table_backup
        echo "New Directory created [ $table_backup ]"
fi

if [ ! -d $logs ];then
        mkdir -p $logs
        echo "New Directory created [ $logs ]"
fi
# END - creation of directory structure.
cd $BASE_PATH

log_file=`date +%Y%m%d_db_tunning_backup_script_log.txt`
log_file_path=${logs}${log_file}

echo "****************************************************************************************" > $log_file_path
echo "******************-------------Table Export Start at: `date`----------******************" >> $log_file_path
echo $MASTER_DB_TABLES >> $log_file_path
Master_db_table=`echo $MASTER_DB_TABLES|tr "," " "`

for table in $Master_db_table
do
	mysqldump $MASTER_DB $table -u${DB_USERNAME} -p${DB_PASSWD}  > "${table_backup}/`date +%Y%m%d`_${table}.sql"
done

echo "******************-------------Procedure Calling for Truncation: `date`----------********" >> $log_file_path
#GUI Management Queries
#mysql -u${DB_USERNAME} -p${DB_PASSWD} $MASTER_DB  -e "DELETE  FROM tbl_daily_mis WHERE shortcode NOT IN ('*354#','*357#','*139#','*777#','*456#','*595#','*356#','*456#','*358#','*999#','*522#','*515#','*560#','*530#','*599#','*598#','*503#','*444#','*355#','*350#','*352','*527#','*531#','*363#','*518#','*510#','*888#','*935#','0');"

echo "******************-------------Schema Export Start at: `date`----------******************" >> $log_file_path
echo $DATABASES >> $log_file_path
DB=`echo $DATABASES|tr "," " "`

for database in $DB
do
	mysqldump --databases $database  -u${DB_USERNAME} -p${DB_PASSWD} -R --no-data=true   > "${schema_backup}/`date +%Y%m%d`_${database}.sql"
done

echo "******************-------------Schema Export End at: `date`----------********************" >> $log_file_path
echo "*********----Delete old Schema / backup /logs /  START at: `date`----********************" >> $log_file_path

if [ -d $schema_backup ]; then
	cd $schema_backup
	filename=`yest -${no_of_days_keep_the_schema_backup} +%Y%m%d`*.sql
	echo ${schema_backup}/$filename >> $log_file_path
	rm -f $filename
fi

if [ -d $table_backup ]; then
	cd $table_backup
	filename=`yest -${no_of_days_keep_the_table_backup} +%Y%m%d`*.sql
	echo ${table_backup}/$filename >> $log_file_path
	rm -f $filename
fi

if [ -d $logs ]; then
	cd $logs
	filename=`yest -${no_of_days_keep_the_script_logs} +%Y%m%d`*.sql
	echo ${logs}/$filename >> $log_file_path
	rm -f $filename
fi
echo "*********----Delete old Schema / backup /logs / END at: `date`-------********************" >> $log_file_path

echo "*****************-----------DB Tunning Started at  at: `date`---------*******************" >> $log_file_path
cd $BASE_PATH
echo $DATABASES >> $log_file_path
DB1=`echo $DATABASES|tr "," " "`

for database in $DB1
do
	sh performance.sh --optimize $database >> "${logs}`date +%Y%m%d`_DBTunning.txt"
	sh performance.sh --repair $database >> "${logs}`date +%Y%m%d`_DBTunning.txt"
done

echo "************************------DB Tunning finished  at: `date`-------*********************" >> $log_file_path
