#!/bin/sh
# ###########################################################################################################################
#=== USSD-MIS.sh ===
#Contributors: (mohitmehral@gmail.com )
#Tags: linux, mysql db
#Requires at least: no specific rpm required
#Stable tag: 2.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
# NAME_="PUSH_USSD_MIS_CIRCLEWISE"
# PURPOSE_="Write Daily Stats for PUSSD."
# REQUIRES_=""
prev_day=0
log_date=`date +%Y%m%d --date="$prev_day days ago"`

# Define Path and other variables in this block
FILE_PATH="/home/ussd/ussd_bin/ussd_log/"
BILL_PATH="/home/ussd/ussd_bin/ussd_log/LOGS/"
MISPATH="/home/ussd/push_mis/PUSHMIS_CIRCLEWISE/"
FINALMISPATH="/home/ussd/push_mis/PUSHMIS_CIRCLEWISE/MIS/"
MISPATH1="/home/ussd/push_mis/mis/"
# ###########################################################################################################################

### No user Changable parts below, kindly refrain from changes ###


echo "______________________ PushUssd MIS Circlewise Dated: $log_date ___________________________"
echo ""
echo ""
echo "______________________________ S  U  M  M  A  R  Y ______________________________"
echo ""
>"$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt
>"$MISPATH"PUSH_MIS_ALLCIRCLE_2.txt
>"$MISPATH"REVENUE_MIS.txt

cat "$FILE_PATH"tempFailedUSSDLog_"$log_date"*.txt | grep -v "notify" | awk -F"," '{ print "tempF~"substr($2,3,4)"~"$5  }' | sort | uniq -c | awk -F" " '{ print $2"~"$1  }' > "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt
cat "$FILE_PATH"permaUSSDFailedLog_"$log_date"*.txt| grep -v "notify" | awk -F"," '{ print "permF~"substr($2,3,4)"~"$5  }' | sort | uniq -c | awk -F" " '{ print $2"~"$1  }' >> "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt
cat "$BILL_PATH""$log_date"*-billing.cdr |awk -F"#" '{ print "billed~"substr($3,1,4) }' | sort | uniq -c | awk -F" " '{ print $2"~0~"$1  }' >> "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt

#cat "$FILE_PATH"tempFailedUSSDLog_"$log_date"*.txt | grep -v "notify" | grep -v "CROSPRM" |awk -F"," '{ print "tempF~"substr($2,3,4)"~"$5  }' | awk -F" " '{ print $2"~"$1  }' > "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt
#cat "$FILE_PATH"permaUSSDFailedLog_"$log_date"*.txt| grep -v "notify" | grep -v "CROSPRM" |awk -F"," '{ print "permF~"substr($2,3,4)"~"$5  }' |  awk -F" " '{ print $2"~"$1  }' >> "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt
#cat "$BILL_PATH""$log_date"*-billing.cdr |awk -F"#" '{ print "billed~"substr($3,1,4) }' |  awk -F" " '{ print $2"~0~"$1  }' >> "$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt


echo " First Result File Created at /home/ussd/push_mis/PUSHMIS_CIRCLEWISE/ "
##############################################################
while read LINE
do

record=$LINE
#echo $record

record_len=${#record}
record_len=`expr $record_len + 0 `
if [ $record_len -lt 14 ]; then
echo Invalid Token in file: $record
else
dt=`echo $log_date`
fl=`echo $record | awk -F"~" '{ print $1 }'`
sr=`echo $record | awk -F"~" '{ print $2 }'`
er=`echo $record | awk -F"~" '{ print $3 }'`
cn=`echo $record | awk -F"~" '{ print $4 }'`
echo $sr
cir=`mysql -h192.168.29.11 -uroot -prnd SIP -e "SELECT GET_CIRCLE_ID($sr,'series');"`
cir=`echo $cir | awk -F" " '{ print $2 $3 }'`

echo $dt"~"$fl"~"$sr"~"$er"~"$cn"~"$cir>>"$MISPATH"PUSH_MIS_ALLCIRCLE_2.txt
fi
done<"$MISPATH"PUSH_MIS_ALLCIRCLE_1.txt

##################################################################
mysql -h192.168.29.11 -uroot -prnd SIP -e "select concat(circle,'~',sum(amount)) from VIEW_USSD_BILLING_CDRS where status=1 and mode in ('pussd','pusssd') and type in ('0') and date_format(date_time,'%d%m%y')=date_format(date_sub(now(), interval $prev_day day),'%d%m%y') group by circle;" | awk -F" " '{ print $1$2 }'> "$MISPATH"REVENUE_MIS.txt

echo "Circle,Pushed,Delivered,Conversions,Delevery%,Conversion%,Revenue" >"$FINALMISPATH"ALLCIRCLES_PUSH_MIS_"$log_date".csv

while read line
do

circle=$line

record=$circle
delv=`awk /$circle/  "$MISPATH"PUSH_MIS_ALLCIRCLE_2.txt | awk -F"~" '{ if(  $2 == "tempF" && ( $4 == 0   || $4 == 3   || $4 == 34 )  ) sum += $5 } END {print sum }'`
totl=`awk /$circle/  "$MISPATH"PUSH_MIS_ALLCIRCLE_2.txt | awk -F"~" '{ if(  $2 == "tempF" || $2 == "$permF"  ) sum += $5  } END {print sum }'`
bill=`awk /$circle/  "$MISPATH"PUSH_MIS_ALLCIRCLE_2.txt | awk -F"~" '{ if(  $2 == "billed"  ) sum += $5 } END { print sum }'`
revn=`awk /$circle/  "$MISPATH"REVENUE_MIS.txt | awk -F"~" '{ print $2 }'`

delv=`expr $delv + 0 `
totl=`expr $totl + 0 `
bill=`expr $bill + 0 `
revn=`expr $revn + 0 `
delp=$(echo "scale=2;$delv*100 / $totl " | bc)
conp=$(echo "scale=3;$bill*100 / $delv " | bc)


echo $circle,$totl,$delv,$bill,$delp,$conp,$revn >>"$FINALMISPATH"ALLCIRCLES_PUSH_MIS_"$log_date".csv

t_delv=`expr $t_delv + $delv + 0 `
t_totl=`expr $t_totl + $totl + 0 `
t_bill=`expr $t_bill + $bill + 0 `
t_revn=`expr $t_revn + $revn + 0 `

t_delp=$(echo "scale=2;$t_delv*100 / $t_totl " | bc)
t_conp=$(echo "scale=3;$t_bill*100 / $t_delv " | bc)

done<"$MISPATH"circle.txt
echo "All Circles,"$t_totl,$t_delv,$t_bill,$t_delp,$t_conp,$t_revn >>"$FINALMISPATH"ALLCIRCLES_PUSH_MIS_"$log_date".csv


ftp -vn <<EOF
open 192.168.29.11
user apps apps
lcd "$FINALMISPATH"
cd MIS_ALL_CSV
put ALLCIRCLES_PUSH_MIS_"$log_date".csv
close
EOF
