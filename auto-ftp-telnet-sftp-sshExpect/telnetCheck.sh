#!/bin/bash
D=10.171.1.134;
M=10.168.1.134;
K=10.164.2.134;
C=10.166.1.134;
port=9882
echo "CHECKING DELHI";
nc -w 1 $D $port ;echo $?
echo "CHECKING Mum";
nc -w 1 $M  $port;echo $?
echo "CHECKING Kol";
nc -w 1 $K  $port;echo $?
echo "CHECKING ChnI";
nc -w 1 $C  $port;echo $?