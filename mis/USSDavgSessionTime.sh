#!/bin/bash
DATE=`date +%Y-%m-%d`
logfile=/home/ussd/gateway/log/mm/2013040220-ussd-success.txt
masterfile="/home/ussd/gateway/log/mm/master_2013040220.txt"
dateraw="/home/ussd/gateway/log/mm/data.txt"
uniqTid="/home/ussd/gateway/log/mm/uniqTID.txt"
>$masterfile
>$uniqTid
cat $logfile|awk -F"," '{print $16}'|sort|uniq >$uniqTid
>$dateraw
cat $logfile|awk -F"," '{print $15","$16","$1}' >$dateraw

cat  $uniqTid | while read tid
do
        cat $dateraw |egrep "$tid" |awk -F"," '{ print $3 }'>/home/ussd/gateway/log/mm/tmp.txt
        shortcode=`cat $dateraw |egrep "$tid" |awk -F"," '{ print $1 }'|sort|uniq`
        totTran=`cat /home/ussd/gateway/log/mm/tmp.txt|wc -l`
        startTime=`cat /home/ussd/gateway/log/mm/tmp.txt| head -1`
        endTime=`cat /home/ussd/gateway/log/mm/tmp.txt| tail -1`
        # Compute the seconds since epoch for date 1
        t1=`date --date="$startTime" +%s`
        # Compute the seconds since epoch for date 2
        t2=`date --date="$endTime" +%s`
        # Compute the difference in dates in seconds
        let "tDiff=$t2-$t1"
        # Compute the approximate hour difference
        let "hDiff=$tDiff"

        echo $shortcode,$tid,$startTime,$endTime,$totTran,$hDiff >> $masterfile
done
