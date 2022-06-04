#!/bin/bash

[[ -d build ]] || mkdir build
cd build/

if [[ ${HOST} =~ .*linux.* ]]; then
  # Missing g++ workaround.
  ln -s ${GXX} g++ || true
  chmod +x g++
  export PATH=${PWD}:${PATH}
fi

export QMAKE_CXXFLAGS+=${CXXFLAGS}
export QMAKE_CFLAGS+=${CFLAGS}

# Need to specify these QMAKE variables because of build environment residue
# in qt mkspecs referencing "qt_1548879054661"
# https://github.com/conda-forge/qtlocation-feedstock/pull/3#issuecomment-466278804
qmake \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    QMAKE_CXXFLAGS += -std=c++14 \
    ../qtlocation.pro
make -j$CPU_COUNT
make check
make install

# Try building "examples/" as a test
echo "Building examples to test library install"
mkdir -p examples
cd examples/

qmake \
    QMAKE_CC=${CC} \
    QMAKE_CXX=${CXX} \
    QMAKE_LINK=${CXX} \
    QMAKE_RANLIB=${RANLIB} \
    QMAKE_OBJDUMP=${OBJDUMP} \
    QMAKE_STRIP=${STRIP} \
    QMAKE_AR="${AR} cqs" \
    QMAKE_CXXFLAGS += -std=c++14 \
    ../../examples/examples.pro

make -j$CPU_COUNT > /dev/null
make check > /dev/null
