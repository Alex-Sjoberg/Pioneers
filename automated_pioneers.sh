#!/bin/sh

date >> date.txt
I=0
while [ $I -le 10 ]
do
    echo "We are starting a new game :) :) :)"
    gnome-terminal -x sh -c "pioneers-server-console -c 3 2>> server_dump.txt" 
    sleep 1
    ./run.sh 2>> client_dump.txt
    killall pioneers-server-console
    I=$(($I+1))
done

python python_results.py

date >> date.txt

