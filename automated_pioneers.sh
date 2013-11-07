#!/bin/sh
#automated script file for running out pioneers simulations
#Brandon Reppert, Alex Sjoberg, Phil Brocker, Seungyoung Ji

echo "Starting new simulation..." > date.txt
date >> date.txt #get start time (used to find total run time)
I=1
while [ $I -le 1999 ] #specify the number of times (n+1) to run the program
do
    echo "We are starting a new game :) :) :)"
    gnome-terminal -x sh -c "pioneers-server-console -c 2 2>&1 | grep 'won' >> server_dump.txt"  #start pioneers server
    sleep 1
    timeout 240 ./run.sh 2>> /dev/null #client_dump.txt (client logging turned off)  #start cleints
    killall pioneers-server-console #kill server when game is over
    I=$(($I+1))
done

python python_results.py #run the python parser to parse results

date >> date.txt #get end time 
