#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

qmake ../qtlocation.pro

make -j$CPU_COUNT
make check
make install

# Try building "examples/" as a test
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake ../../examples/examples.pro

make -j$CPU_COUNT > /dev/null
make check > /dev/null
