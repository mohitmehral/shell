#!/bin/bash

##=== parseLogs.sh ===
#Contributors: (mohitmehral@gmail.com )
#Tags: log.txt
#Requires at least: no specific rpm required
#Stable tag: 2.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#==description===== 
#Cut logs from the below format log file
#Date/Time : 4/1/2012 10:24:46 PM Mobile number : 918858690133 msg : MTP 8303850612 20 Response Time : 4/1/2012 10:24:52 PM Response : Thanks! you have successfully recharged 8303850612 with Rs.20 at 01-04-12 10:21:23(TID:12040122243657805741). Bal:In=-55,cur=Closing balance:-75 - powered by SpiceD
#Date/Time : 4/1/2012 10:33:08 PM Mobile number : 919999593583 msg : MTP 8750829522 30 Response Time : 4/1/2012 10:33:15 PM Response : null(Transaction ID:120401223303265EF2C3).Opening balance:480 and Closing balance:481 - powered by Spice
#Date/Time : 4/1/2012 3:31:36 PM Mobile number : 919887177591 msg : MTP 7737184166 125 TATA_DOKOMO Response Time : 4/1/2012 3:31:36 PM Response : Sorry! This is an invalid format.Kindly send SMS as MTP<space><Mobile Number><space><Amount><space><Operator><space>[Recharge/Topup] OR [Flexi/Special]
#=== Revision History ===
#
# Date        Name              Reason
# ----        ----              ------
# 06-03-2012  Mohit Mehral      cut required field
###################################################################################################




LOG_PATH="/tmp/test"

DATE=`date -d "1 day ago" +%Y-%m-%d`
FILENAME=${DATE}_euro_log.txt

REQ_FILENAME=${DATE}_euro_Reqlog.csv
RESP_FILENAME=${DATE}_euro_Resplog.csv




cat ${LOG_PATH}/${FILENAME} | while read line
do
        DATETIME=`echo $line | awk -F "::" '{print $2}' | awk -F "Request" '{print $1}'`
        merchantrefno=`echo $line | awk -F "merchantrefno=" '{print $2}' | awk -F "&" '{print $1}'`
        consumerno=`echo $line | awk -F "consumerno=" '{print $2}' | awk -F "&" '{print $1}'`
        amount=`echo $line | awk -F "amount=" '{print $2}' | awk -F "&" '{print $1}'`
        spcode=`echo $line | awk -F "spcode=" '{print $2}' | awk -F "&" '{print $1}'`
        optional1=`echo $line | awk -F "optional1=" '{print $2}' | awk -F "&" '{print $1}'`
        optional2=`echo $line | awk -F "optional2=" '{print $2}' | awk -F "&" '{print $1}'`

        REQ_LOG=`echo ${DATETIME},${merchantrefno},${consumerno},${amount},${spcode},${optional1},${optional2}`

        merchantrefno=`echo $line | awk -F "merchantrefno=" '{print $2}' | awk -F "&" '{print $1}'`
        enrefno=`echo $line | awk -F "enrefno=" '{print $2}' | awk -F "&" '{print $1}'`
        responsecode=`echo $line | awk -F "responsecode=" '{print $2}' | awk -F "&" '{print $1}'`
        operatorrefno=`echo $line | awk -F "operatorrefno=" '{print $2}' | awk -F "&" '{print $1}'`
        responsemessage=`echo $line | awk -F "responsemessage=" '{print $2}' | awk -F "&" '{print $1}'`
        responseaction=`echo $line | awk -F "responseaction=" '{print $2}' | awk -F "&" '{print $1}'`

        RESP_LOG=`echo ${DATETIME},${merchantrefno},${enrefno},${responsecode},${operatorrefno},${responsemessage},${responseaction}`

        echo $REQ_LOG >> ${LOG_PATH}/${REQ_FILENAME}
        echo $RESP_LOG >> ${LOG_PATH}/${RESP_FILENAME}

done
