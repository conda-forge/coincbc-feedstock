#!/usr/bin/env bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Cgl
cp $BUILD_PREFIX/share/gnuconfig/config.* .
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/Glpk
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/Lapack
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Data/miplib3
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/Blas
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Clp
cp $BUILD_PREFIX/share/gnuconfig/config.* ./BuildTools
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/ASL
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/Mumps
cp $BUILD_PREFIX/share/gnuconfig/config.* ./ThirdParty/Metis
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Cbc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Data/Sample
cp $BUILD_PREFIX/share/gnuconfig/config.* ./Osi
cp $BUILD_PREFIX/share/gnuconfig/config.* ./CoinUtils
set -e

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  cd ThirdParty/ASL && ./get.ASL && cd -
fi

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

if [ "${UNAME}" == "Linux" ]; then
  export FLIBS="-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm"
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

WITH_BLAS_LIB="-L${PREFIX}/lib -lblas"
WITH_LAPACK_LIB="-L${PREFIX}/lib -llapack"

./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-blas-lib="${WITH_BLAS_LIB}" \
  --with-lapack-lib="${WITH_LAPACK_LIB}" \
  --enable-cbc-parallel \
  || { echo "PRINTING CONFIG.LOG"; cat config.log; echo "PRINTING CoinUtils/CONFIG.LOG"; cat CoinUtils/config.log; exit 1; }
make -j "${CPU_COUNT}"
if [ "${UNAME}" == "Linux" ]; then
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make test
fi
fi
make install
