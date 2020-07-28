#!/bin/sh
# Copyright 2020 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
# Add to /etc/inittab something like 
# m1:2345:respawn:/data/moloch/bin/run_capture.sh

TDIR=/data/moloch

ulimit -l unlimited

/sbin/ethtool -K MOLOCH_INTERFACE tx off sg off gro off gso off lro off tso off
/sbin/ethtool -G MOLOCH_INTERFACE rx 4096 tx 4096

cd ${TDIR}/bin
/bin/rm -f ${TDIR}/logs/capture.log.old
/bin/mv ${TDIR}/logs/capture.log ${TDIR}/logs/capture.log.old

${TDIR}/bin/moloch-capture -c ${TDIR}/etc/config.ini > ${TDIR}/logs/capture.log 2>&1
