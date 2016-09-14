#! /bin/bash

#
# Installation script for dividiti's OpenCL profiler.
#
# See CK LICENSE.txt for licensing details.
# See CK COPYRIGHT.txt for copyright details.
#
# Developer(s):
# - Grigori Fursin, grigori@dividiti.com, 2015
# - Anton Lokhmotov, anton@dividiti.com, 2016
#

# Standard env.
# INSTALL_DIR
# PACKAGE_DIR

# Custom env (./cm/meta.json).
# PACKAGE_URL
# PACKAGE_BRANCH
# PACKAGE_NAME
# LIB_NAME

export SRC_DIR=${INSTALL_DIR}/src
export LIB_DIR=${INSTALL_DIR}/lib
export BLD_DIR=${INSTALL_DIR}/bld
export BLD_LOG=${BLD_DIR}/${PACKAGE_NAME}.log

################################################################################
echo ""
echo "Cloning '${PACKAGE_NAME}' from '${PACKAGE_URL}' ..."

rm -rf ${SRC_DIR}
git clone ${PACKAGE_URL} --no-checkout ${SRC_DIR}
if [ "${?}" != "0" ] ; then
  echo "Error: Cloning '${PACKAGE_NAME}' from '${PACKAGE_URL}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Checking out the '${PACKAGE_BRANCH}' branch of '${PACKAGE_NAME}' ..."

cd ${SRC_DIR}
git checkout ${PACKAGE_BRANCH}
if [ "${?}" != "0" ] ; then
  echo "Error: Checking out the '${PACKAGE_BRANCH}' branch of '${PACKAGE_NAME}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Building '${PACKAGE_NAME}' in '${BLD_DIR}' ..."
echo "Logging into '${BLD_LOG}' ..."

echo "** DATE **" > ${BLD_LOG}
date >> ${BLD_LOG}

echo "** SET **" >> ${BLD_LOG}
set >> ${BLD_LOG}

mkdir -p ${BLD_DIR}
cd ${BLD_DIR}

echo "** CMAKE **" >> ${BLD_LOG}
cmake \
  ${SRC_DIR} \
  -DCMAKE_C_COMPILER=${CK_CC} \
  -DCMAKE_CXX_COMPILER=${CK_CXX} \
  >>${BLD_LOG} 2>&1

echo "** MAKE **" >> ${BLD_LOG}
make \
  -j ${CK_HOST_CPU_NUMBER_OF_PROCESSORS} \
  >>${BLD_LOG} 2>&1  

if [ "${?}" != "0" ] ; then
  echo "Error: Building '${PACKAGE_NAME}' in '${BLD_DIR}' failed!"
  exit 1
fi

################################################################################
echo ""
echo "Copying '${TOOL_NAME}.so' to '${LIB_DIR}' ..."

mkdir -p ${LIB_DIR}

cp -f ${BLD_DIR}/lib/libprof.so ${LIB_DIR}/${TOOL_NAME}.so
if [ "${?}" != "0" ] ; then
  echo "Error: Copying '${TOOL_NAME}' to '${LIB_DIR}' failed!"
  exit 1
fi