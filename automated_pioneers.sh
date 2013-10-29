#!/bin/sh

I=0

while [ $I -le 30 ]
do
    gnome-terminal -x sh -c "pioneers-server-console -c 3" #& #> /dev/null
    sleep 1
    ./run.sh > dump.dat
    killall pioneers-server-console
    I = $I + 1;
done


