#!/bin/sh

date >> date.txt #get start time (used to find toatl run time)
I=0
while [ $I -le 10 ] #specify the number of times to run the program
do
    echo "We are starting a new game :) :) :)"
    gnome-terminal -x sh -c "pioneers-server-console -c 3 2>> server_dump.txt"  #start pioneers server
    sleep 1
    ./run.sh 2>> client_dump.txt #start cleints
    killall pioneers-server-console #kill server when game is over
    I=$(($I+1))
done

python python_results.py #run the python parser to parse results

date >> date.txt #get end time 

