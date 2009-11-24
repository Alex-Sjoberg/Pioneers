#!/bin/bash

INSTALL_DIR=`pwd`

cd pioneers
make distclean
./configure --prefix=$INSTALL_DIR
make
make install
