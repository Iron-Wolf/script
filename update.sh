#!/bin/sh
#FreeDNS updater script
#dans la crontab : 
# @reboot /etc/cron.d/update.sh > /dev/null
# @hourly /etc/cron.d/update.sh > /dev/null

UPDATEURL="https://freedns.afraid.org/dynamic/update.php?########"
DOMAIN="minecraftnoob.com"

registered=$(nslookup $DOMAIN|tail -n2|grep A|sed s/[^0-9.]//g)

  current=$(wget -q -O - http://checkip.dyndns.org|sed s/[^0-9.]//g)
       [ "$current" != "$registered" ] && {
          wget -q -O /dev/null $UPDATEURL
          echo "DNS updated on:"; date
  }
