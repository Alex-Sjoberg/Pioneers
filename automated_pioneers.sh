gnome-terminal -x sh -c "pioneers-server-console -c 3" #& #> /dev/null
serverid = $!

#i = 0

#while i < 30
#do
    sleep 1
    ./run.sh #>> dump.dat
#    i = $i + 1;
#done


killall pioneers-server-console
