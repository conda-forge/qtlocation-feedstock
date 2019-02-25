#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

# Need to specify these QMAKE variables because of build environment residue
# in qt mkspecs referencing "qt_1548879054661"
# https://github.com/conda-forge/qtlocation-feedstock/pull/3#issuecomment-466278804
qmake \
    QMAKE_LIBDIR=/usr/lib64 \
    QMAKE_INCDIR=/usr/include \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ../qtlocation.pro

# Log files on Travis CI are limited to 4MB and this step usually exceeds
# that limit. Removes ability to diagnose, but lets the build complete.
if [ $(uname) == Darwin ]; then
    echo "Silencing make step while running on Travis-CI"
    make -j$CPU_COUNT > /dev/null
    make check > /dev/null
    make install
else
    make -j$CPU_COUNT
    make check
    make install
fi

# Try building "examples/" as a test
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake \
    QMAKE_LIBDIR=/usr/lib64 \
    QMAKE_INCDIR=/usr/include \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    ../../examples/examples.pro

if [ $(uname) == Darwin ]; then
    echo "Silencing make step while running on Travis-CI"
    make -j$CPU_COUNT > /dev/null
    make check > /dev/null
else
    make -j$CPU_COUNT
    make check
fi
