#!/bin/sh
#####################################################################################
##=== smpp_alerts.sh ===
#Contributors: (mohitmehral@gmail.com )
#Tags: monitoring linux system - dialogic binaries
#Requires at least: no specific rpm required
#Stable tag: 1.0
#License: GPLv2 or later
#License URI: Mohit Mehral | https://www.apnok.com/licenses/gpl-2.0.html | mohitmehral@gmail.com
#== Description ==
#This script use 
#  1. Check Gctload & other Binary process id restart if not running
#  2. Check Gctload Status & send alerts   -----restart gctload if it crosses 10000 limit
#  3. Check Ques Pendency and sender alerts.
#####################################################################################
# Setting Path Variables
#####################################################################################


print_help()
{
    echo ""
    echo "Please give correct argument which start with '-a' can be:"
    echo "Please don't put any space between -a and argument"
    echo "1)push"
    echo "2)pull"
    echo "2)common"
    echo "e.g [#]./every_min_gw_check.sh -a common"
    exit
}


######## READ PARAMETER FROM INPUT###########
if [[ $# == 1 ]];then
  INPUT=$1
  check=`echo  $INPUT | grep -a "^-a.*" | wc -l`
    if [[ $check == 1 ]];then
       check_parameter_input=`echo $INPUT | awk -F"-a" '{print $2}'`
       echo "Processing for $check_parameter_input ..."
    fi
else
    print_help
fi

#DB detail for inserting alerts
MIS_USER=root
MIS_PASS=rnd
MIS_DB=oam
HOST_NAME=`hostname`
HOST=0.0.0.0  # COMMENT: what is this?

######## CREATING LOG FILES##########
log_file=`date +%Y%m%d_alert_log.txt`
log_file_path="logs/$log_file" #### COMMENT:  use absolute path. because when we run this from cron or some other path
  if [ ! -d ./logs ];then	### then there might be some issue.
        mkdir -p logs
  fi

######## GENERAL PARAMETERS#########
DATE=`date +%Y-%m-%d" "%H:%M`
curr_time=`date +%H |awk '{print $1}'`
mesg="No message"
Query="mysql -h$HOST -u$MIS_USER -p$MIS_PASS $MIS_DB -e "
# Variable to store the name of the file containing binaries list
queuefile="queues.txt"

echo "##################Start#####################" >> $log_file_path
echo "Script executed at `date`" >> $log_file_path


# Check for  binaries
   find  binaries/ -name $check_parameter_input &> testing.txt  #### COMMENT: read the use of &> should it be used here?
   test=`cat testing.txt|wc -l`					#### what if there is no such folder as biaries?	
   if [ $test -eq 0 ]
   then
           mesg="Wrong Parameter. Please Pass Valid Parameter"
           echo "$mesg" >> $log_file_path
           echo "$mesg"
           print_help
           rm testing.txt  ### COMMENT: Will this cmd be executed?
    else 
            ############# READ PROCESS NAME FROM BINARY FILE##############
	     cat binaries/${check_parameter_input}|while read binary
             do
                # Extract first character of every line
 		       first=`echo $binary | cut -c1`
       		 # If line is empty do nothing
       		       if [ -z $first ]
        		then
                		continue
       		        fi

       		 # If line starts with a '#' do nothing
       		 if [ $first = \# ]
       		 then
               		 continue
  
      		  # Else test for the command
       		 else
                        process=`echo $binary|cut -d '~' -f1`
                        process_run=`echo $binary|cut -d '~' -f22`  #### COMMENT: 22?
                         ##### CHECK PROCESS RUNNING##########
                         ps -C $process &> /dev/null
                         if [ $? -ne 0 ]
                          then
			     ######## RUN PROCESS#############
                             cd $process_path    
                             ${process_run}	
		                                      #### COMMENT: Use cd -

  			     mesg="$process restarted on $DATE on $HOST_NAME"
		             echo $mesg
 		 	     echo "$mesg" >> $log_file_path   ### COMMENT: If you are not doing cd - then where will
                        				      ### this log be written??
                          else
                              mesg="$process Working Fine on $DATE on $HOST_NAME"
                              echo $mesg
		             # echo "$mesg" >> $log_file_path
				
	               	 fi
	           fi
	        ############ Check for Process Running more than 1###########

                     pgrep -f $process > pid.txt
                     count=`cat pid.txt | wc -l`
                        if [ $count -ge 2 ]
                        then
                                count1=`expr $count - 1`
                                pid=`cat pid.txt | head -$count1`
                               
				 # To make log
                                 echo "$process service running $count times at `date` with ID $pid " >> $log_file_path
                                # Kill Duplicate Process
                                	for kill_pid in $pid
                                	do
                                           kill -9 $kill_pid
                                	done
                         fi 
	
   	             done
             rm  testing.txt	#### COMMENT: why here?
   fi	

##################### ALERT 1 = GCTLOAD RUNNING or NOT ##################################

ps -C gctload &> /dev/null

# If gctload is not running do following
if [ $? -ne 0 ]
then

        mesg="$HOST_NAME: gctload not running. Singnalling Down `date`"
        echo "$HOST_NAME: gctload not running. Singnalling Down`date`" >> $log_file_path

        echo $mesg

        exit
else
        echo "Gctload is working fine"
        gctcount=`/opt/septel/gctload -t1 | grep 'MSGs allocated' | head --lines=1 | awk '{ print $3}'`
        if [ "$gctcount" -ge 200 ]
        then
                mesg="`$HOST_NAME`: Gctload pendency is $gctcount at `date` please check !!"
                echo "`$HOST_NAME`: High gctload Pendency count = $gctcount at `date`" >> $log_file_path
                echo $mesg
                ## Send alert to DB
               ### $Query "call proc_Alerts('$mesg','Gctload','$HOST_NAME')" > /dev/null &

        fi
fi

   

########### Queue Check Of DB###################
cat $queuefile | while read binary
do
        # Extract first character of every line
        first=`echo $binary | cut -c1`
        # If line is empty do nothing
        if [ -z $first ]
        then
                continue
        fi
       # If line starts with a '#' do nothing
        if [ $first = \# ]
        then
                continue
        # Else test for the command
        else

                #check if the queue exists or not
                hexvalue="`echo $binary  | cut -d "~" -f1`"
                qname="`echo $binary | cut -d "~" -f2`"
                qcount=`ipcs -q | grep "$hexvalue" | wc -l`
                if [ "$qcount" -eq 0 ]
                 then
                #       echo "Queue not created "
                        mesg="$HOST_NAME Q$name not created pls chk`date`"
			echo $mesg
                        echo $mesg >> $log_file_path
                else
                       # echo "Queue present, now checking pendency"
                        qpendency=`ipcs -q | grep "$hexvalue" | awk '{ print $6}'`

                        echo "$HOST_NAME: Message $qname pendency: $qpendency"
                        if [ "$qpendency" -gt 200 ]
                        then
                                mesg="$HOST_NAME: $qname q pendency=$qpendency Please chk !!!`date`"
                                #$Query "call proc_Alerts('$mesg','Q','$CLI')"
                                echo $mesg >> $log_file_path
				echo $mesg
                        fi


                fi

                #Pick up the queue Id and search it in the output of IPCS command
                # parse the output using Awk to get the number
                #
        fi
done


#This script fill the Operation and Maintaines tab values, shown in UI
./oam.sh -a${check_parameter_input}
