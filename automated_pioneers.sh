#!/bin/sh

I=0
while [ $I -le 3 ]
do
    echo "We are starting a new game :) :) :)"
    sleep 5
    gnome-terminal -x sh -c "pioneers-server-console -c 3" #& #> /dev/null
    sleep 1
    ./run.sh
    killall pioneers-server-console
    I=$(($I+1))
done


