#!/bin/bash

INSTALL_DIR=`pwd`

cd pioneers-0.12.2
make distclean
./configure --prefix=$INSTALL_DIR
make
make install
