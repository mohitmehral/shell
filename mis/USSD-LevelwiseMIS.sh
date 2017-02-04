PULL_PATH=/home/ussd/gateway/log/
DIR=/home/ussd/gateway/menu_files/
SUFFIX=.txt
log_path=/home/ussd/gateway/log/mm/
log_date=`date +%Y%m%d --date=" 0 days ago"`
INPATH=/home/ussd/gateway/log/
MIS_USER=root
MIS_PASS=rnd
MIS_DB=ussd_mis
MIS_DB1=ussd
HOST=localhost
date_time=`date +%d-%m-%Y --date=" 1 days ago"`
dbdate=`date +%Y-%m-%d --date=" 1 days ago"`
#echo -e "$dbdate"
prev_day=1
echo -e "***********************************************************************************">"$log_path""$log_date"".txt"
echo -e "***************************  BSNL USSD MIS  FOR $log_date ************************">>"$log_path""$log_date"".txt"
echo -e "***********************************************************************************">>"$log_path""$log_date"".txt"
echo -e "" >>"$log_path""$log_date"".txt"
echo -e "TRANSACTIONS:-">>"$log_path""$log_date"".txt"

echo -e "">>"$log_path""$log_date"".txt"

echo -e "******************************* LEVEL WISE BROWSING *******************************">>"$log_path""$log_date"".txt"
echo -e "">>"$log_path""$log_date"".txt"
echo -e "Shortcode\t\t\tLevel\t\t\t\tCount" >>"$log_path""$log_date"".txt"
echo -e "">>"$log_path""$log_date"".txt"
echo -e "">>"$log_path""$log_date"".txt"

while read LINE
do
var_sc=$LINE
echo -e "">>"$log_path""$log_date"".txt"
echo -e "$var_sc :-">>"$log_path""$log_date"".txt"
echo -e "---------------------------------------------------------------------------------------">>"$log_path""$log_date"".txt"
cat "$PULL_PATH""$log_date"*-ussd-success.txt| grep "$var_sc" | awk -v var="$var_sc" -F"," '{ if( $15 == var ) print $16 }' | sort | uniq -c | awk -F" " '{ print $1 }' | sort |uniq -c | awk -v var="$var_sc" -F" " '{ if( $2 < 100 ) print "\t\t\t\tLevel "$2"\t\t\t\t"$1 }' | sort -n >>"$log_path""$log_date"".txt"
echo -e "---------------------------------------------------------------------------------------">>"$log_path""$log_date"".txt"
done </home/ussd/gateway/log/mm/shortcode_level.cfg
echo -e "">>"$log_path""$log_date"".txt"
echo -e "">>"$log_path""$log_date"".txt"
echo -e "">>"$log_path""$log_date"".txt"

echo -e " ***********************************************************************************">>"$log_path""$log_date"".txt"
echo -e " *********************************** END OF MIS ************************************">>"$log_path""$log_date"".txt"
echo -e " ***********************************************************************************">>"$log_path""$log_date"".txt"
