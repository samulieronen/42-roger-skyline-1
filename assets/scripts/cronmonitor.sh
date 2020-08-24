#!/bin/bash
SUM="/var/tmp/checksum"
FILE="/var/spool/cron/crontabs/seronen"
NEWSUM=$(sudo md5sum $FILE)

if [ ! -f $SUM ]
then
	 echo "$NEWSUM" > $SUM
	 exit 0;
fi;

if [ "$NEWSUM" != "$(cat $SUM)" ];
	then
	echo "$NEWSUM" > $SUM
	echo "$FILE has been modified! Actions required." | mail -s "$FILE modified! Actions required." root
fi;
