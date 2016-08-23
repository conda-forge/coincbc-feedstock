#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  export CC=gcc
  export CXX=g++
else
  # for Linux
  export CC=
  export CXX=
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
WITH_LAPACK_LIB="-L${PREFIX}/lib -llapack"

ls

CC="${CC}" CXX="${CXX}" ./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-blas-lib="${WITH_BLAS_LIB}" \
  --with-lapack-lib="${WITH_LAPACK_LIB}" \
  || { cat config.log; exit 1; }
make
if [ "${UNAME}" == "Linux" ]; then
  make test
fi
make install
