#!/bin/bash

INSTALL_DIR=`pwd`

cd pioneers
make distclean
./autogen.sh
./configure --prefix=$INSTALL_DIR
make
make install
echo ""
echo ""
echo "Please put your settlers/bin/ directory in your path! (e.g., 'export PATH=/home/[user]/settlers/bin/:\$PATH')"
