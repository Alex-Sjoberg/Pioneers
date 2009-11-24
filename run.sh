#!/bin/bash

cd pioneers-0.12.2
make && make install && ../bin/pioneersai -s 127.0.0.1 -p 5556 -n Computer -c -a expert
