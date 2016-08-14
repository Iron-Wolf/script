#!/bin/sh

ping -q -w 1 -c 1 192.168.1.1 > /dev/null

if [ `echo $?` -eq 0 ]; then
	/etc/init.d/nginx stop;
	/root/letsencrypt/letsencrypt-auto certonly --standalone -d www.########.netlib.re --standalone-supported-challenges tls-sni-01 --renew-by-default;
	/etc/init.d/nginx start;
fi
