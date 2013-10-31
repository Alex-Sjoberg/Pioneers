#!/bin/bash

var1=$1
var2=$2

if [ -z $1 ]; then
	var1="alex"
fi
if [ -z $2 ]; then
	var2="expert"
fi

cd pioneers
#make && make install && 
../bin/pioneersai -s $HOSTNAME.cse.taylor.edu -p 5556 -n $var1 -c -a $var2 
