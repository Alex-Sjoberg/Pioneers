#!/bin/bash

cd pioneers-0.12.2
make && make install && ../bin/pioneersai -s localhost -p 5556 -n Computer -c -a expert
