#!/bin/bash

username="wladimirlinuxcali@gmail.com"
password="13N3m3zu3l4"

curl -u $username:$password --silent "https://mail.google.com/mail/feed/atom" > emailresult

cat emailresult | grep -oPm1 "(?<=<title>)[^<]+" | sed '1d' > title
cat emailresult | grep -oPm1 "(?<=<modified>)[^<]+" | sed '1d' >  date
sed -e 's/^/|/' -i date
paste title date > merge

diff merge lastmerge
if [ $? -ne 0 ]; then
    #echo "Channel: TRUNKname/xxxxxxx" > /etc/asterisk/alarm.call
    #echo "MaxRetries: 2" >> /etc/asterisk/alarm.call
    #echo "RetryTime: 60" >> /etc/asterisk/alarm.call
    #echo "WaitTime: 30" >> /etc/asterisk/alarm.call
    #echo "application: Playback" >> /etc/asterisk/alarm.call
    #echo "data: /path/to/sound/file.wav" >> /etc/asterisk/alarm.call
    #chmod 777 /etc/asterisk/alarm.call
    #chown asterisk:asterisk /etc/asterisk/alarm.call
    #mv /etc/asterisk/alarm.call /var/spool/asterisk/outgoing/

    #echo "Channel: TRUNKname/xxxxxxx" > /etc/asterisk/alarm.call
    echo "MaxRetries: 2" >>  /home/wladimir/p/1.call
    echo "RetryTime: 60" >> /home/wladimir/p/1.call
    echo "WaitTime: 30" >>  /home/wladimir/p/1.call
    echo "application: Playback" >>  /home/wladimir/p/1.call
    echo "data: /path/to/sound/file.wav" >> /home/wladimir/p/1.call




else
    echo "No New Email"

fi

mv merge -f lastmerge
