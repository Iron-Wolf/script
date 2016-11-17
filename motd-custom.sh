#!/bin/bash

echo -en "\033[31m"
cat << "EOF"
          _,met$$$$$gg.
       ,g$$$$$$$$$$$$$$$P.
     ,g$$P""       """Y$$.".
    ,$$P'              `$$$. 
  ',$$P       ,ggs.     `$$b:
  `d$$'     ,$P"'   .    $$$
   $$P      d$'     ,    $$P
   $$:      $$.   -    ,d$$'
   $$;      Y$b._   _,d$P'
   Y$$.    `.`"Y$$$$P"' 
   `$$b      "-.__
    `Y$$b
     `Y$$.
       `$$b.
         `Y$$b.
           `"Y$b._
               `""""
EOF
echo -en "\033[0m"

memTot="$(top -bn1 | awk '/Mem/ {print $3}' | head -n 1)";
memUsed="$(top -bn1 | awk '/Mem/ {print $5}' | head -n 1)";
cpuUsed="$(top -bn1 | awk '/Cpu/ {print $8}' | head -n 1 | awk -F',' '{print $1}')";

curRam="$(echo "$memUsed/$memTot*100" | bc -l | awk -F'.' '{print $1 "%"}')";
curCpu="$(echo "100 - $cpuUsed" | bc -l)";
curHome="$(df /home | awk '{print $5}' | tail -n 1)";

col1="\e[0;0m";  # white
col2="\e[0;31m"; # red
col3="\e[0;33m"; # dark yellow
col4="\e[1;33m"; # yellow


#echo -en "$col1   System.......$col2=$col3 "; /bin/uname -snrvm | awk -F" " '{print $4}';
echo -en "$col1   System.......$col2=$col3 "; uname -v;
echo -en "$col1   Release......$col2=$col3 "; cat /etc/*release | grep PRETTY | cut -d'"' -f2;
echo -en "$col1   Kernel.......$col2=$col3 "; uname -rs;
echo -en "$col1   Uptime.......$col2=$col3 "; awk '{print int($1/86400)" day "int($1%86400/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime;
echo -en "$col1   Load.........$col2=$col3 "; 
echo -en "$col4`cat /proc/loadavg | cut -d' ' -f1`$col3 (1min), ";
echo -en "$col4`cat /proc/loadavg | cut -d' ' -f2`$col3 (5min), ";
echo -en "$col4`cat /proc/loadavg | cut -d' ' -f3`$col3 (15min)";echo

echo -en "$col1   Usage........$col2=$col3 "; echo -e "$col4$curRam$col3 RAM, $col4$curCpu%$col3 CPU, $col4$curHome$col3 Home";
echo -en "$col1   Process......$col2=$col3 "; top -bn1 | awk '/Tasks/ {print $2 " total, " $4 " running"}'
echo -en "$col1   IP...........$col2=$col3 "; ip route get 8.8.8.8 | head -1 | cut -d' ' -f8;

echo -e "\033[0m";
