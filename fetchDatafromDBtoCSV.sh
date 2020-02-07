#!/usr/bin/bash
#. ~/.bash_profile
ORACLE_HOSTNAME=oel45.localdomain; export ORACLE_HOSTNAME
ORACLE_BASE=/home/oracle/app; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/client_1; export ORACLE_HOME
ORACLE_TERM=xterm; export ORACLE_TERM
PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH
PREV_DATE=`date --date="1 day ago" "+%d-%m-%Y"`



EXTRACT_FILE()
{

	FILE=$1
	QUERY=$2
# password contain special char. add / to ignore
	sqlplus -s  mohituser/\(\:OZ\!MK5\)@SID  <<EOF

	SET COLSEP ,
	set pagesize 0 embedded on
	SET TERMOUT OFF
	SET VERIFY OFF
	SET ECHO OFF
	SET FEEDBACK OFF
	SET HEADING ON
	SET TRIMSPOOL ON
	SET LINES 1000
	set linesize 2000
	SET SQLBLANKLINES OFF
        set longchunksize 20000000 long 20000000 pages 0
        column txt format a500
	alter session set nls_date_format='dd:mm:yyyy:hh24:mi:ss';
	
	SPOOL $FILE

	$QUERY
	
	SPOOL OFF
	EXIT
EOF

	#echo "$(tail -n +2 $FILE)" > $FILE

}

NOW=`date "+%d"`
FILE1='MAX-Transaction'$NOW'.csv'


echo "PR- details"
echo " "
echo "MAX Transactions Time"

echo " "
set +x


EXTRACT_FILE "$FILE1" "select * from (
select to_char(max(TRANS_DATE),'dd-mm-yyyy::hh24:mi:ss') TRANS_DATE,TRANS_TYPE,TRANS_STATUS,COMMENTS from 
mcommerce.T_WALLET_TRANSACTIONIONA where comments not like '%MONTHLY RENTAL%' and  
trunc(TRANS_DATE) >=trunc(sysdate) group by TRANS_TYPE,TRANS_STATUS,COMMENTS,TRANS_MODE ) order by TRANS_DATE desc;"
